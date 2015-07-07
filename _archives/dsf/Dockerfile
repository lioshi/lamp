# LAMP Docker

FROM debian:jessie
MAINTAINER lioshi <lioshi@lioshi.com>


# Update

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get upgrade -y


# Base Dependencies

RUN apt-get install -y software-properties-common wget \
  git --version 

# PHP

RUN apt-get install -y php-pear php5-cgi php5-json php5-cli php5-curl curl \
  php5-mcrypt php5-xdebug mcrypt libmcrypt-dev php5-mysql php5-gd php5-sqlite \
  php5-intl php5-imap vim graphviz parallel imagemagick php5-imagick \
  sqlite && \
  php5enmod mcrypt pdo pdo_sqlite sqlite3 && \
  php --version
ADD configs/php/php-cli.ini /etc/php5/cli/conf.d/php-cli.ini


# Node.js

RUN apt-get install -y nodejs npm && \
  nodejs --version && \
  npm --version && \
  npm install -g less less-plugin-autoprefix less-plugin-group-css-media-queries
RUN echo "alias node='nodejs'" >> ~/.bashrc
RUN ln -s /usr/bin/nodejs /usr/bin/node


# Utility Packages

RUN apt-get install -y mysql-client unzip


# Clean up

RUN apt-get clean && apt-get autoremove


# Apache

ADD configs/apache2/apache2-service.sh /apache2-service.sh
RUN apt-get install -y apache2 && \
  chmod +x /*.sh && \
  a2enmod rewrite
ADD configs/apache2/apache_default /etc/apache2/sites-available/000-default.conf
ADD configs/apache2/supervisor.conf /etc/supervisor/conf.d/apache2.conf


# Apache2 conf
RUN echo "# Include vhost conf" >> /etc/apache2/apache2.conf 
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf 
RUN echo "IncludeOptional /data/docker-diem/conf/*.conf" >> /etc/apache2/apache2.conf 
RUN echo "<Directory /data/docker-diem/www> " >> /etc/apache2/apache2.conf 
RUN echo "    Options Indexes FollowSymLinks Includes ExecCGI" >> /etc/apache2/apache2.conf 
RUN echo "    AllowOverride None" >> /etc/apache2/apache2.conf 
RUN echo "    Require all granted" >> /etc/apache2/apache2.conf 
RUN echo "</Directory>" >> /etc/apache2/apache2.conf 

# Timezone settings
ENV TIMEZONE="Europe/Paris"
RUN echo "date.timezone = '${TIMEZONE}'" >> /etc/php5/cli/php.ini && \
  echo "${TIMEZONE}" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata


# PHP

RUN apt-get install -y libapache2-mod-php5 php5 php5-json php5-cli php5-curl curl php5-mcrypt php5-xdebug mcrypt libmcrypt-dev
ADD configs/php/php.ini /etc/php5/apache2/conf.d/30-docker.ini


# MySQL

ADD configs/mysql/mysql-setup.sh /mysql-setup.sh
ADD configs/mysql/my.cnf /etc/mysql/conf.d/my.cnf
ADD configs/mysql/supervisor.conf /etc/supervisor/conf.d/mysql.conf
RUN apt-get install -y mysql-server mysql-client php5-mysql && \
  chmod +x /*.sh && \
  /mysql-setup.sh


# PHPMyAdmin

RUN (echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections)
RUN (echo 'phpmyadmin phpmyadmin/app-password password root' | debconf-set-selections)
RUN (echo 'phpmyadmin phpmyadmin/app-password-confirm password root' | debconf-set-selections)
RUN (echo 'phpmyadmin phpmyadmin/mysql/admin-pass password root' | debconf-set-selections)
RUN (echo 'phpmyadmin phpmyadmin/mysql/app-pass password root' | debconf-set-selections)
RUN (echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections)
RUN apt-get install phpmyadmin -y
ADD configs/phpmyadmin/config.inc.php /etc/phpmyadmin/conf.d/config.inc.php
RUN chmod 755 /etc/phpmyadmin/conf.d/config.inc.php
ADD configs/phpmyadmin/phpmyadmin-setup.sh /phpmyadmin-setup.sh
RUN chmod +x /phpmyadmin-setup.sh
RUN /phpmyadmin-setup.sh

# Start

VOLUME /var/www/html
EXPOSE 22 80 3306
