FROM debian:oldstable

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y default-mysql-client


RUN  apt-get install -y curl \
	&& apt-get install -y php php-fpm php-mysql \
	&& apt-get install -y php-mysql && apt-get install -y php-mysqli

RUN	apt clean \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

RUN chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

RUN ln -s /usr/sbin/php-fpm* /usr/bin/php-fpm || true


COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh



ENTRYPOINT ["/usr/bin/entrypoint.sh"]
