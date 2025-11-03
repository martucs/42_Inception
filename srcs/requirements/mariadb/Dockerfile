FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY mariadb_init.sh /usr/local/bin/mariadb_init.sh

RUN chmod +x /usr/local/bin/mariadb_init.sh

#RUN rm -rf /var/lib/mysql/*

ENTRYPOINT ["/usr/local/bin/mariadb_init.sh"]

#ENTRYPOINT ["mysqld", "mariadb"] -> esto da error prq el servidor mysqld no puede recibir argumentos
#ENTRYPOINT ["mariadb"] -> esto iniciaria el programa cliente, no el servidor de mariadb (mysqld) y tmb da error, prq no encuentra el socket del servidor porque obv aun no estaria funcionando el programa servidor/deamon de mariadb(mysqld)
