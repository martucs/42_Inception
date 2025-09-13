FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

#ENTRYPOINT ["mariadb"] -> esto iniciaria el programa cliente, no el servidor de mariadb (mysql)
ENTRYPOINT ["mysqld"]
