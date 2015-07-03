FROM debian:jessie
MAINTAINER lioshi <lioshi@lioshi.com>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update 
RUN apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php5-mcrypt php5-intl php5-imap vim graphviz nodejs npm parallel

# Install less node packages
RUN npm install -g less  
RUN npm install -g less-plugin-autoprefix 
RUN npm install -g less-plugin-group-css-media-queries

#Install imagick
RUN apt-get -y install imagemagick php5-imagick 
#RUN apachectl restart

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

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config Apache
RUN a2enmod rewrite

# Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add dirs for manage sites (mount from host in run needeed for persistence)
RUN mkdir /data && mkdir /data/docker-diem && mkdir /data/docker-diem/conf && mkdir /data/docker-diem/www && mkdir /data/docker-diem/lib && mkdir /data/docker-diem/mysql

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

# Add volumes for sites, confs and libs and mysql from host
# /data/docker-diem/conf : apache conf file
# /data/docker-diem/www  : site's file
# /data/docker-diem/lib  : external libs
VOLUME  ["/data"]

# Add alias
RUN echo "alias node='nodejs'" >> ~/.bashrc

# Add links
RUN ln -s /usr/bin/nodejs /usr/bin/node

EXPOSE 80 3306
CMD ["/run.sh"] 
