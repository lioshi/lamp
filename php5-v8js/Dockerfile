 
FROM debian:jessie
MAINTAINER lioshi <lioshi@lioshi.com>

# Tweaks to give MySQL write permissions to the app
#ENV BOOT2DOCKER_ID 1000
#ENV BOOT2DOCKER_GID 50
#
#RUN useradd -r mysql -u ${BOOT2DOCKER_ID} && \
#    usermod -G staff mysql
#
#RUN groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1)
#RUN groupmod -g ${BOOT2DOCKER_GID} staff

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN mkdir -p /var/cache/apt/archives/partial
RUN touch /var/cache/apt/archives/lock
RUN chmod 640 /var/cache/apt/archives/lock
RUN apt-get clean && apt-get update
#RUN apt-get update --fix-missing 

RUN apt-get -y install supervisor apt-utils git apache2 lynx libapache2-mod-php5 php5-dev mysql-server php5-mysql php5-curl php5-gd pwgen php5-mcrypt php5-intl php5-imap vim graphviz parallel cron jpegoptim optipng locales

#Install v8js
# RUN apt-get -y install libv8-dev php-pear
# RUN echo "\n" | pecl install v8js-0.1.3
# RUN echo "extension=v8js.so" >> /etc/php5/apache2/php.ini

#Install imagick
RUN apt-get -y install imagemagick php5-imagick 
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
RUN echo "date.timezone = '${TIMEZONE}'" >> /etc/php5/apache2/php.ini && \
  echo "${TIMEZONE}" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="fr_FR.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=fr_FR.UTF-8
ENV LANG fr_FR.UTF-8 
ENV LC_ALL fr_FR.UTF-8  

# Add image configuration and scripts
ADD ../start-apache2.sh /start-apache2.sh
ADD ../start-mysqld.sh /start-mysqld.sh
#ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD ../my.cnf /etc/mysql/conf.d/my.cnf
ADD ../supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD ../supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD ../create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config Apache
RUN a2enmod rewrite


