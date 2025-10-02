FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

ENTRYPOINT ["mysqld"]

#ENTRYPOINT ["mysqld", "mariadb"] -> esto da error prq el servidor mysqld no puede recibir argumentos
#ENTRYPOINT ["mariadb"] -> esto iniciaria el programa cliente, no el servidor de mariadb (mysqld) y tmb da error, prq no encuentra el socket del servidor
