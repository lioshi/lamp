#!/bin/bash

# Mysql
VOLUME_HOME="/var/lib/mysql" 

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini

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



# Mysql persist with cron
echo "MYSQL_PERSIST_CRON : ${MYSQL_PERSIST_CRON}"
if [ -z "${MYSQL_PERSIST_CRON}" ] 
then
  echo "No env var MYSQL_PERSIST_CRON in docker run command. Do nothing."
else 
  if [ "${MYSQL_PERSIST_CRON}" = "yes" ]
  then
    echo "Env var MYSQL_PERSIST_CRON value is yes. Launch a crontab to backup mysql dir."
    if [ -z "${MYSQL_PASS}" ] 
    then
      PASS="admin"
    else 
      PASS=${MYSQL_PASS}
    fi
    

# http://www.ekito.fr/people/run-a-cron-job-with-docker/
# écrire un fichier de cron qui est mappé

    echo "* * * * * mysqldump -u admin -p$PASS --all-databases > /data/all_dbs.sql
    " >> mycron
    crontab mycron
    rm mycron
    cron    # launch cron exec job
 
  else
    echo "Env var MYSQL_PERSIST_CRON value must be with yes. Do nothing."
  fi
fi

  

    
# Create sample site (site.loc)
echo "SITE_SAMPLE : ${SITE_SAMPLE}"
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





exec supervisord -n -c /etc/supervisor/supervisord.conf

