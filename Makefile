doker-compose := docker-compose


up:
	$(docker-compose) up

build:
	$(docker-compose) build

down:
	$(docker-compose) down

clean:
	$(docker-compose) down --rmi all

.PHONY: up build down clean