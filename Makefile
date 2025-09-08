DOCKER-COMPOSE := docker-compose

COMPOSE_FILE = srcs/docker-compose.yml

export COMPOSE_FILE


up:
	@if [ ! -d /home/$(USER)/data/mysql ] || [ ! -d /home/$(USER)/data/wordpress]; then \
		mkdir -p /home/$(USER)/data/mysql; \
		mkdir -p /home/$(USER)/data/wordpress; \
	fi
	
	$(DOCKER-COMPOSE) up

build:
	$(DOCKER-COMPOSE) build

down:
	$(DOCKER-COMPOSE) down -v

clean:
	$(DOCKER-COMPOSE) down --rmi all

re: clean build up


.PHONY: up build down clean