DOCKER-COMPOSE := docker-compose

COMPOSE_FILE = srcs/docker-compose.yml

export COMPOSE_FILE


up:
	$(DOCKER-COMPOSE) up

build:
	$(DOCKER-COMPOSE) build

down:
	$(DOCKER-COMPOSE) down -v

clean:
	$(DOCKER-COMPOSE) down --rmi all


.PHONY: up build down clean