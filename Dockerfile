################################################## OLD ##############################################################
# FROM debian:jessie
# MAINTAINER lioshi <lioshi@lioshi.com>

# # Install packages
# ENV DEBIAN_FRONTEND noninteractive
# RUN mkdir -p /var/cache/apt/archives/partial
# RUN touch /var/cache/apt/archives/lock
# RUN chmod 640 /var/cache/apt/archives/lock
# RUN apt-get clean 
# RUN apt-get update --fix-missing

# # PHP7 lamp version
# RUN apt-get -y install apt-transport-https lsb-release ca-certificates
# RUN apt-get -y install wget
# RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
# RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
# RUN apt-get update
# RUN apt-get -y install --no-install-recommends supervisor apt-utils git apache2 lynx mysql-server pwgen php7.1 libapache2-mod-php7.1 php7.1-mysql php7.1-curl php7.1-json php7.1-gd php7.1-mcrypt php7.1-msgpack php7.1-memcached php7.1-intl php7.1-sqlite3 php7.1-gmp php7.1-geoip php7.1-mbstring php7.1-xml php7.1-zip php7.1-imap php7.1-soap vim graphviz parallel cron jpegoptim optipng locales

# #Install v8js (compile version)
# RUN apt-get -y install build-essential python libglib2.0-dev curl 

# # LIB V8 compilation
# RUN cd /tmp && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
# ENV PATH=${PATH}:/tmp/depot_tools
# # RUN cd /tmp && fetch --no-history v8
# RUN cd /tmp && fetch v8
# RUN cd /tmp/v8/ && git checkout 6.5.257 && gclient sync && tools/dev/v8gen.py -vv x64.release -- is_component_build=true && ninja -C /tmp/v8/out.gn/x64.release/ 
# RUN mkdir -p /opt/v8/lib && mkdir -p /opt/v8/include
# RUN cp /tmp/v8/out.gn/x64.release/lib*.so /opt/v8/lib/ && cp -R /tmp/v8/include/* /opt/v8/include
# RUN cp /tmp/v8/out.gn/x64.release/natives_blob.bin /opt/v8/lib
# RUN cp /tmp/v8/out.gn/x64.release/snapshot_blob.bin /opt/v8/lib
# RUN cd /tmp/v8/out.gn/x64.release/obj && ar rcsDT libv8_libplatform.a v8_libplatform/*.o && echo -e "create /opt/v8/lib/libv8_libplatform.a\naddlib /tmp/v8/out.gn/x64.release/obj/libv8_libplatform.a\nsave\nend" | sudo ar -M`
# # RUN mkdir -p /opt/v8/lib && mkdir -p /opt/v8/include 
# # RUN cp /tmp/v8/out.gn/x64.release/lib*.so /tmp/v8/out.gn/x64.release/*_blob.bin /tmp/v8/out.gn/x64.release/icudtl.dat /opt/v8/lib/ 
# # RUN cp -R /tmp/v8/include/* /opt/v8/include/
# # RUN apt-get install patchelf
# # RUN for A in /opt/v8/lib/*.so; do patchelf --set-rpath '$ORIGIN' $A; done
# # RUN cd /tmp && git clone https://github.com/phpv8/v8js.git
# RUN cd /tmp && git clone https://github.com/phpv8/v8js.git
# RUN apt-get update
# RUN apt-get -y install php7.1-dev
# # RUN cd /tmp/v8js/ && git checkout php7 && phpize && ./configure --with-v8js=/opt/v8 LDFLAGS="-lstdc++" && make && make install
# # RUN git checkout issue-374 
# RUN cd /tmp/v8js/ && phpize && ./configure --with-v8js=/opt/v8 LDFLAGS="-lstdc++" && make && make install && echo "extension=v8js.so" >> /etc/php/7.1/apache2/php.ini
#####################################################################################################################

# FROM php:7.2-fpm
FROM debian:stretch
MAINTAINER lioshi <lioshi@lioshi.com>

# Build V8
RUN apt-get update && \
    apt-get install -y bzip2 wget git g++ python libicu-dev libmagickwand-dev libpq-dev zlib1g-dev software-properties-common && \
    #add-apt-repository ppa:ondrej/php && \
    apt-get -y install apt-transport-https lsb-release ca-certificates gnupg gnupg2 gnupg1 && \
    wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - && \
    echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    apt-get install -y libapache2-mod-php7.1 php7.1-cli php7.1-mysql php7.1-gd php7.1-imagick php7.1-recode php7.1-tidy php7.1-xmlrpc supervisor apt-utils git apache2 lynx mysql-server pwgen php7.1-curl php7.1-json php7.1-msgpack php7.1-memcached php7.1-intl php7.1-sqlite3 php7.1-gmp php7.1-geoip php7.1-mbstring php7.1-xml php7.1-zip php7.1-imap php7.1-soap vim graphviz parallel cron jpegoptim optipng locales && \
    git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git /tmp/depot_tools && \
    export PATH="$PATH:/tmp/depot_tools" && \
    cd /usr/local/src && \
    fetch v8 && \
    cd v8 && \
    git checkout 6.0.292 && \
    gclient sync && \
    tools/dev/v8gen.py x64.release -- is_component_build=true && \
    ninja -C out.gn/x64.release && \
    cd /usr/local/src/v8 && \
    cp out.gn/x64.release/lib*.so out.gn/x64.release/*_blob.bin /usr/lib && \
    cp -R include/* /usr/include && \
    cd out.gn/x64.release/obj && \
    ar rcsDT libv8_libplatform.a v8_libplatform/*.o && \
    echo "create /usr/lib/libv8_libplatform.a\naddlib /usr/local/src/v8/out.gn/x64.release/obj/libv8_libplatform.a\nsave\nend" | ar -M && \
    rm -rf /tmp/depot_tools /usr/local/src/v8 && \
    apt-get autoremove -y


RUN apt-get install -y patchelf php7.1-dev
RUN for A in /usr/lib/*.so; do patchelf --set-rpath '$ORIGIN' $A; done

RUN pecl install v8js




# RUN cd /tmp && git clone https://github.com/phpv8/v8js.git
# RUN apt-get update
# # RUN apt-get -y install php7.1-dev
# # RUN cd /tmp/v8js/ && git checkout php7 && phpize && ./configure --with-v8js=/opt/v8 LDFLAGS="-lstdc++" && make && make install
# # RUN git checkout issue-374 
# RUN cd /tmp/v8js/ && phpize && ./configure LDFLAGS="-lstdc++" && make && make install

RUN echo "extension=v8js.so" >> /etc/php/7.1/apache2/php.ini



#Install imagick
RUN apt-get -y install imagemagick php7.1-imagick libapache2-mod-xsendfile 

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
  echo "${TIMEZONE}" > /etc/timezone && dpkg-reconfigure --frontend=noninteractive tzdata

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
RUN a2enmod ssl

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
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.8.5/phpMyAdmin-4.8.5-all-languages.zip -P /var/www/html/
RUN apt-get -q -y install unzip
RUN unzip /var/www/html/phpMyAdmin-4.8.5-all-languages.zip -d /var/www/html/
RUN mv /var/www/html/phpMyAdmin-4.8.5-all-languages/ /var/www/html/phpmyadmin/
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


