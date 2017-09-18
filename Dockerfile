# FROM debian:jessie
FROM ubuntu:trusty
MAINTAINER lioshi <lioshi@lioshi.com>

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN dpkg-divert --local --rename --add /sbin/initctl && \
	ln -sf /bin/true /sbin/initctl && \
	mkdir /var/run/sshd && \
	mkdir /run/php && \
	
	apt-get update && \
	apt-get install -y --no-install-recommends apt-utils \ 
		software-properties-common \
		python-software-properties \
		language-pack-en-base && \

	LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \

	apt-get update && apt-get upgrade -y && \

	apt-get install -y python-setuptools \ 
		curl \
		git \
		nano \
		sudo \
		unzip \
		openssh-server \
		openssl \
		supervisor \
		nginx \
		memcached \
		ssmtp \
		cron && \

	# Install PHP
	apt-get install -y \
		php7.1-mysql \
	    php7.1-curl \
	    php7.1-gd \
	    php7.1-intl \
	    php7.1-mcrypt \
	    php-memcache \
	    php7.1-sqlite \
	    php7.1-tidy \
	    php7.1-xmlrpc \
	    php7.1-pgsql \
	    php7.1-ldap \
	    freetds-common \
	    php7.1-pgsql \
	    php7.1-sqlite3 \
	    php7.1-json \
	    php7.1-xml \
	    php7.1-mbstring \
	    php7.1-soap \
	    php7.1-zip \
	    php7.1-cli \
	    php7.1-sybase \
	    php7.1-odbc \
        apache2 \
        lynx \
        mysql-server \
        pwgen \
        php7.1 \
        libapache2-mod-php7.1 \
        php7.1-json \
        php7.1-msgpack \
        php7.1-memcached \
        php7.1-gmp \
        php7.1-geoip \
        php7.1-mbstring \
        php7.1-xml \
        php7.1-zip \
        php7.1-imap \
        graphviz \
        parallel \
        cron \
        jpegoptim \
        optipng \
        locales 

# Install v8js / V8 (PECL with ppa version)
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:pinepain/libv8-5.4
RUN apt-get update -y
RUN apt-get install -y libv8-5.4
RUN apt-get -y install php-pear php7.1-dev
RUN pecl install v8js
RUN echo "extension=v8js.so" >> /etc/php/7.1/apache2/php.ini 

# Install v8js / V8 (compile version)
# RUN apt-get -y install build-essential python libglib2.0-dev
# RUN cd /tmp && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
# ENV PATH=${PATH}:/tmp/depot_tools
# RUN cd /tmp && fetch --no-history v8
# RUN cd /tmp/v8/ && tools/dev/v8gen.py -vv x64.release -- is_component_build=true && ninja -C out.gn/x64.release/ && mkdir -p /opt/v8/lib && mkdir -p /opt/v8/include && cp out.gn/x64.release/lib*.so out.gn/x64.release/*_blob.bin out.gn/x64.release/icudtl.dat /opt/v8/lib/ && cp -R include/* /opt/v8/include/
# RUN cd /tmp && git clone https://github.com/phpv8/v8js.git
# RUN apt-get update
# RUN apt-get -y install php7.1-dev
# RUN cd /tmp/v8js/ && phpize && ./configure --with-v8js=/opt/v8 && make && make test && make install
# RUN echo "extension=v8js.so" >> /etc/php/7.1/apache2/php.ini

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
RUN locale-gen fr_FR.UTF-8
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:en
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


