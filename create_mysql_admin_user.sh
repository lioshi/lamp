#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

if [ -z "${MYSQL_PASS}" ] 
then
  PASS="admin"
else 
  PASS=${MYSQL_PASS}
fi

_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "default" )
echo "=> Creating MySQL admin user with ${_word} password"

mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"


echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
#echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'admin' has password '$PASS'"
echo "MySQL user 'root' has password 'root' but only allows local connections"
echo "========================================================================"






# Mysql persist with cron
echo "MYSQL_PERSIST_BY_CRON : "
if [ -z "${MYSQL_PERSIST_BY_CRON}" ] 
then
  echo "No env var MYSQL_PERSIST_BY_CRON in docker run command. Do nothing."
else 
  if [ "${MYSQL_PERSIST_BY_CRON}" = "yes" ]
  then
    echo "Env var MYSQL_PERSIST_BY_CRON value is yes. Launch a crontab to backup mysql dir."
    # get pass used in docker run or default admin pass
    if [ -z "${MYSQL_PASS}" ] 
    then
      PASS="admin"
    else 
      PASS=${MYSQL_PASS}
    fi

    # restore database if exits file
    if [ ! -f /data/MYSQL_PERSIST_BY_CRON_all_dbs.sql ]; then
      echo "No file /data/MYSQL_PERSIST_BY_CRON_all_dbs.sql. Use an empty mysql server."
    else
      echo "File /data/MYSQL_PERSIST_BY_CRON_all_dbs.sql exists. Use it to restore all databases."
      mysql -u admin -p$PASS < /data/MYSQL_PERSIST_BY_CRON_all_dbs.sql
    fi
    
    # backup all database all minute by cron rask
    echo "* * * * * mysqldump -u admin -p$PASS --all-databases > /data/MYSQL_PERSIST_BY_CRON_all_dbs.sql
    " >> mycron
    crontab mycron
    rm mycron
    cron    # launch cron exec job
 
  else
    echo "Env var MYSQL_PERSIST_BY_CRON value must be with yes. Do nothing."
  fi
fi






# phpmyadmin configuration
# Change the MySQL root password
mysqladmin -u root password root

# Create the phpmyadmin storage configuration database.
mysql -uroot -proot -e "CREATE DATABASE phpmyadmin; GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'root'@'localhost' IDENTIFIED BY 'root'; FLUSH PRIVILEGES;"

# Import the configuration storage database.
gunzip < /usr/share/doc/phpmyadmin/examples/create_tables.sql.gz | mysql -u root -proot phpmyadmin

# Shutdown the server.
mysqladmin -u root -proot shutdown


