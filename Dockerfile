FROM debian:jessie
MAINTAINER lioshi <lioshi@lioshi.com>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN mkdir -p /var/cache/apt/archives/partial
RUN touch /var/cache/apt/archives/lock
RUN chmod 640 /var/cache/apt/archives/lock
RUN apt-get clean && apt-get update
#RUN apt-get update --fix-missing

# PHP7 lamp version
RUN apt-get -y install apt-transport-https lsb-release ca-certificates
RUN apt-get -y install wget
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
RUN apt-get update
RUN apt-get -y install --no-install-recommends supervisor apt-utils git apache2 lynx mysql-server pwgen php7.1 libapache2-mod-php7.1 php7.1-mysql php7.1-curl php7.1-json php7.1-gd php7.1-mcrypt php7.1-msgpack php7.1-memcached php7.1-intl php7.1-sqlite3 php7.1-gmp php7.1-geoip php7.1-mbstring php7.1-redis php7.1-xml php7.1-zip php7.1-imap vim graphviz parallel cron jpegoptim optipng locales

#Install v8js (compile version)
RUN apt-get -y install build-essential python libglib2.0-dev
RUN cd /tmp && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH=${PATH}:/tmp/depot_tools
RUN cd /tmp && fetch --no-history v8
RUN cd /tmp/v8/ && tools/dev/v8gen.py -vv x64.release -- is_component_build=true && ninja -C out.gn/x64.release/ && mkdir -p /opt/v8/lib && mkdir -p /opt/v8/include && cp out.gn/x64.release/lib*.so out.gn/x64.release/*_blob.bin out.gn/x64.release/icudtl.dat /opt/v8/lib/ && cp -R include/* /opt/v8/include/
RUN cd /tmp && git clone https://github.com/phpv8/v8js.git
RUN apt-get update
RUN apt-get -y install php7.1-dev
RUN cd /tmp/v8js/ && phpize && ./configure --with-v8js=/opt/v8 && make && make test && make install
RUN echo "extension=v8js.so" >> /etc/php/7.1/apache2/php.ini

#Install imagick
RUN apt-get -y install imagemagick php7.1-imagick 
RUN apt-get -y install libapache2-mod-xsendfile 

# Apache2 conf
RUN echo "# Include vhost conf" >> /etc/apache2/apache2.conf 
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf 
RUN echo "IncludeOptional /data/lamp/conf/*.conf" >> /etc/apache2/apache2.conf 
RUN echo "<Directory /data/lamp/www> " >> /etc/apache2/apache2.conf 
RUN echo "    Options Indexes FollowSymLinks Includes ExecCGI" >> /etc/apache2/apache2.conf 
RUN echo "    AllowOverride None" >> /etc/apache2/apache2.conf 
RUN echo "    Require all granted" >> /etc/apache2/apache2.conf 
RUN echo "</Directory>" >> /etc/apache2/apache2.conf 

# Timezone settings
ENV TIMEZONE="Europe/Paris"
RUN echo "date.timezone = '${TIMEZONE}'" >> /etc/php/7.1/apache2/php.ini && \
  echo "${TIMEZONE}" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="fr_FR.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=fr_FR.UTF-8
ENV LANG fr_FR.UTF-8 
ENV LC_ALL fr_FR.UTF-8  

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
#ADD run.sh /run.sh
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
ENV PHP_MEMORY_LIMIT 1024M

# Add dirs for manage sites (mount from host in run needeed for persistence)
RUN mkdir /data && mkdir /data/lamp && mkdir /data/lamp/conf && mkdir /data/lamp/www 

RUN chown -R mysql:mysql /var/lib/mysql

# Add volumes for MySQL 
VOLUME  [ "/etc/mysql", "/var/lib/mysql" ]

# Add volumes for sites, confs and libs and mysql from host
# /data/lamp/conf : apache conf file
# /data/lamp/www  : site's file
VOLUME  ["/data"]

# Add alias
RUN echo "alias node='nodejs'" >> ~/.bashrc

# Add links
RUN ln -s /usr/bin/nodejs /usr/bin/node

# Phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.7.2/phpMyAdmin-4.7.2-all-languages.zip -P /var/www/html/
RUN apt-get -q -y install unzip
RUN unzip /var/www/html/phpMyAdmin-4.7.2-all-languages.zip -d /var/www/html/
RUN mv /var/www/html/phpMyAdmin-4.7.2-all-languages/ /var/www/html/phpmyadmin/
RUN cp /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php
ADD configs/phpmyadmin/config.inc.php /var/www/html/phpmyadmin/config.inc.php
RUN chmod 755 /var/www/html/phpmyadmin/config.inc.php

# Symfony 2 pre requisted
RUN apt-get -y install curl
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer


ADD run.sh /run.sh
RUN chmod 755 /*.sh

EXPOSE 80 3306

CMD ["/run.sh"]


