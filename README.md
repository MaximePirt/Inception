# Inception

Projet système de l'école 42 : mettre en place, à la main et avec Docker, une
petite infrastructure web composée de plusieurs services qui tournent chacun
dans leur propre conteneur.

## Architecture

```
                 ┌────────────┐
   HTTPS :443    │   nginx    │   TLS only, reverse proxy + serveur statique
 ───────────────▶│  (Debian)  │
                 └─────┬──────┘
                       │ FastCGI :9000
                 ┌─────▼──────┐
                 │ wordpress  │   PHP-FPM + WP-CLI
                 │  (Debian)  │
                 └─────┬──────┘
                       │ MySQL :3306
                 ┌─────▼──────┐
                 │  mariadb   │
                 │  (Debian)  │
                 └────────────┘
```

Chaque service est construit depuis une image `debian:oldstable` (pas d'image
toute faite pour le service lui-même) et possède son propre `Dockerfile` +
script `entrypoint.sh` dans `srcs/requirements/`.

- **nginx** : unique point d'entrée, en écoute sur le port 443 uniquement
  (TLS 1.2/1.3), avec génération automatique d'un certificat auto-signé au
  premier démarrage. Sert les fichiers statiques et relaie les requêtes
  `.php` à WordPress en FastCGI.
- **wordpress** : PHP-FPM + [WP-CLI](https://wp-cli.org/), installe et
  configure WordPress au démarrage (téléchargement du core, `wp-config.php`,
  création du site) sans interface d'installation web.
- **mariadb** : initialise la base et les utilisateurs au premier démarrage
  (création de la base, de l'utilisateur applicatif, suppression des bases
  de test) puis démarre le serveur.

## Réseaux et volumes

- Deux réseaux Docker bridge dédiés : `db` (wordpress ↔ mariadb) et `proxy`
  (nginx ↔ wordpress), ce dernier avec l'IPv6 activé.
- Deux volumes persistants partagés via bind mount dans `srcs/tmp/` :
  les fichiers WordPress (`wordpressfiles`) et les données MariaDB
  (`dbwordpress`).
- Les certificats TLS sont montés depuis `secrets/nginx/certs/`.

## Prérequis

- Docker et Docker Compose
- Un fichier `srcs/.env` définissant les variables utilisées par les
  conteneurs : domaine (`DOMAIN_NAME`, `WP_DNS`), base de données
  (`DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_ROOT_PASSWORD`, `DB_HOST`),
  compte admin WordPress (`ADMIN_USER`, `ADMIN_USER_PSWD`) et chemin
  d'installation (`WP_PATH`).

## Utilisation

```bash
make build   # build les images des 3 services
make up      # build + démarre l'infrastructure (docker-compose up)
make down    # arrête les conteneurs
make clean   # arrête et supprime les conteneurs + images
```

Une fois démarré, le site est accessible en HTTPS sur le domaine défini par
`WP_DNS` (ex. `https://mpierrot.42.fr`).

## Ce que ce projet démontre

- Écriture de `Dockerfile` et d'entrypoints pour des services qui
  s'initialisent eux-mêmes (base de données, configuration WordPress,
  certificats) sans étape manuelle après `make up`.
- Orchestration multi-conteneurs avec Docker Compose : dépendances entre
  services, isolation réseau, persistance des données par volumes.
- Mise en place de TLS avec un reverse proxy nginx comme unique point
  d'entrée du réseau.
