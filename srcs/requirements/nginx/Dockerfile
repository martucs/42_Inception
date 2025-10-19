FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create self-signed certificate
RUN mkdir -p /etc/ssl/certs /etc/ssl/private \
    && openssl req -x509 -nodes -days 365 \
        -subj "/CN=martalop.42.fr" \
        -newkey rsa:2048 \
        -keyout /etc/ssl/private/martalop.key \
        -out /etc/ssl/certs/martalop.crt

COPY ./conf/nginx.conf /etc/nginx/sites-available/default

#aqui copiaba mi html personalizado a la carpeta 'html' para que el contenedor pueda acceder
#COPY html/ /var/www/martalop.42.fr/
# y le daba permisos al usuario de FPM (www-data) para poder leerlo luego sin haberlo creado 
#RUN chown -R www-data:www-data /var/www/martalop.42.fr

# Expose HTTPS
EXPOSE 443

# Start NGINX in foreground
CMD ["nginx", "-g", "daemon off;"]
