#!/bin/bash

# Mysql
VOLUME_HOME="/var/lib/mysql" 

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" \
    -e "s/^memory_limit.*/memory_limit = ${PHP_MEMORY_LIMIT}/" /etc/php/7.1/apache2/php.ini

# install db
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

    
# Create sample site (site.loc)
echo "========================================================================"
echo "SITE_SAMPLE : "
if [ -z "${SITE_SAMPLE}" ] 
then
	echo "No env var SITE_SAMPLE in docker run command. Do nothing."
else 
	if [ "${SITE_SAMPLE}" = "create" ]
	then
		echo '<VirtualHost *:80>   
  ServerName    site.loc  
  DocumentRoot  /data/lamp/www/site/htdocs  
  AddType         application/x-httpd-php .php  
  DirectoryIndex  index.php  
  CustomLog     /data/lamp/www/site/log/request.log combined  
  KeepAlive Off  
  <Directory /data/lamp/www/site/htdocs>  
    Options +FollowSymLinks +ExecCGI  
  </Directory>  
</VirtualHost>' > /data/lamp/conf/httpd-site.conf;
		mkdir /data/lamp/www/site;
		mkdir /data/lamp/www/site/htdocs;
		mkdir /data/lamp/www/site/log;
		echo '<h1>Hello site.loc</h1>' > /data/lamp/www/site/htdocs/index.php;
	else
		rm -f /data/lamp/conf/httpd-site.conf;
		rm -Rf /data/lamp/www/site;
	fi
fi


# supervisord
echo "========================================================================"
echo "Supervisord launchs: "
exec supervisord -n -c /etc/supervisor/supervisord.conf



