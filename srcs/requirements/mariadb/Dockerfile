FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
	apt-get install -y mariadb-server \
	&& apt-get install -y gosu \
	&& apt clean \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld \
	&& chown mysql:mysql /run/mysqld

RUN mkdir -p /var/lib/mysql \
	&& chown -R mysql:mysql /var/lib/mysql

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
