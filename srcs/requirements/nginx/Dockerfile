FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl curl

RUN apt-get install -y netcat-traditional nginx-common

COPY conf/nginx.conf /conf/nginx.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
