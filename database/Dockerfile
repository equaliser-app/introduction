FROM mysql:5.7

ENV MYSQL_DATABASE=Equaliser
ENV MYSQL_USER=equaliser_api
ENV MYSQL_PASSWORD=supersecret
ENV MYSQL_RANDOM_ROOT_PASSWORD=yes
ENV MYSQL_ONETIME_PASSWORD=yes

COPY init.sql /docker-entrypoint-initdb.d
COPY utf8.cnf /etc/mysql/conf.d/

EXPOSE 3306
