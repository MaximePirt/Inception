FROM debian:oldstable

RUN apt-get update && apt-get install -y nginx openssl curl

RUN apt-get install -y netcat-traditional nginx-common

COPY conf/nginx.conf_temp /conf/nginx.conf_temp

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
