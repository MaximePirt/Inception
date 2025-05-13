doker-compose := docker-compose

COMPOSE_FILE = srcs/docker-compose.yml

up:
	$(docker-compose) up

build:
	$(docker-compose) build

down:
	$(docker-compose) down

clean:
	$(docker-compose) down --rmi all

.PHONY: up build down clean