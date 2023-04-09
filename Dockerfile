# base docker image from https://hub.docker.com/_/debian
FROM debian

# this directory creates certificate files etc.
WORKDIR /etc/ssl/oneself

# install apache2
RUN apt-get update -y && \
    apt-get install -y tzdata && \
    apt-get install -y apache2

# creates certificate files etc.
RUN openssl genrsa 2048 > server.key && \
    yes '' | openssl req -new -key server.key > server.csr && \
    openssl x509 -in server.csr -days 365 -req -signkey server.key > server.crt

# setup the certificate.
RUN sed -i 's!/etc/ssl/certs/ssl-cert-snakeoil.pem!/etc/ssl/oneself/server.crt!g' /etc/apache2/sites-available/default-ssl.conf && \
    sed -i 's!/etc/ssl/private/ssl-cert-snakeoil.key!/etc/ssl/oneself/server.key!g' /etc/apache2/sites-available/default-ssl.conf

# enable SSL Module, configure for SSL and apache restart.
RUN a2enmod ssl && a2ensite default-ssl.conf && service apache2 restart

# start http in the foreground.
CMD ["apachectl","-D","FOREGROUND"]
