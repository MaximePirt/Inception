FROM debian:oldstable

RUN apt-get update && apt-get install -y nginx openssl

RUN apt-get install -y netcat-traditional

COPY conf/nginx.conf_temp /conf/nginx.conf_temp

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["nginx", "-g", "daemon off;"]
