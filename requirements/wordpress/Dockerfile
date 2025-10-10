FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates php-mysqli php-json wget unzip
#php-mysqli & php-json son extensiones minimas obligatorias que nos pide wordpress

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

#necesitamos tanto curl como wp-cli para instalar wordpress
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php && \
    chmod 777 /run/php

#temporal
COPY .env /root/.env

# wordpress must be installed in the root directory of nginx, so we set the workdir there: 
WORKDIR /var/www/html

COPY wordpress_init.sh /root/wordpress_init.sh

RUN chmod 700 /root/wordpress_init.sh


COPY ./conf/inception_pool.conf /etc/php/7.4/fpm/pool.d/inception

EXPOSE 9000

ENTRYPOINT [ "/root/wordpress_init.sh" ]

CMD [ "php-fpm7.4", "-F" ]
#el -F es para que se ejecute php como deamon


# este comando solo me mantiene el contenedor vivo
#ENTRYPOINT [ "tail", "-f", "/dev/null" ]
