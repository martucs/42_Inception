FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# esta copia de el .env con las contrasenas esta prohibido por subject
# “Passwords must not be present in your Dockerfiles.”
# ademas, aunque lo haga, si creo la imagen con: "docker build -t inception-db srcs/mariadb" desde la carpeta de inception, tampoco me va a dejar copiar el .env por razones de seguridad, porque le he especificado que el build localtion seria la carpeta 'mariadb' y en esa el .env no existe.
COPY .env /root/.env

COPY srcs/mariadb/mariadb_init.sh /usr/local/bin/mariadb_init.sh

RUN chmod +x /usr/local/bin/mariadb_init.sh


ENTRYPOINT ["/usr/local/bin/mariadb_init.sh"]

#ENTRYPOINT ["mysqld", "mariadb"] -> esto da error prq el servidor mysqld no puede recibir argumentos
#ENTRYPOINT ["mariadb"] -> esto iniciaria el programa cliente, no el servidor de mariadb (mysqld) y tmb da error, prq no encuentra el socket del servidor

#todas las rutas dependenden de donde estemos al hacer 'docker run' por ejemplo. Si hagp ese comando desde inception/ no es lo mismo que si lo hago desde /inception/srcs/mariadb. Se ira a buscar el .env depediendo de donde estemos.
