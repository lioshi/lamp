#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
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
echo "MySQL user 'root' has password 'root' but only allows local connections"
echo "========================================================================"


# phpmyadmin configuration

# Change the MySQL root password
mysqladmin -u root password root

# Create the phpmyadmin storage configuration database.
mysql -uroot -proot -e "CREATE DATABASE phpmyadmin; GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'root'@'localhost' IDENTIFIED BY 'root'; FLUSH PRIVILEGES;"

# Import the configuration storage database.
gunzip < /usr/share/doc/phpmyadmin/examples/create_tables.sql.gz | mysql -u root -proot phpmyadmin

# Shutdown the server.
mysqladmin -u root -proot shutdown


