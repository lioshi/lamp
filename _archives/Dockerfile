

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



EXPOSE 80 3306
CMD ["/run.sh"] 
