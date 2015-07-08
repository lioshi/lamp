# Lamp
Docker image for diem sites. Debian with LAMP, nodeJs, imagick... etc

This docker image is used to launch container with all necessary applicatives instances for diem CMF

- Debian
- Apache
- PHP
- Mysql 
- Node
- ImageMagick
- NodeJs
- etc ...

# Usage for site sample

## Launch container

Create local datas. Create host directories.

    mkdir /data 
    mkdir /data/lamp 
    mkdir /data/lamp/conf 
    mkdir /data/lamp/www 

Directory */data/lamp/conf* contains apache conf files for each site
Directory */data/lamp/www* contains site's source's file

Add host locally (in your /etc/hosts file)

	127.0.0.1   site.loc 

Container launching (with sample site create)

	sudo docker run -d -p 80:80 -p 3306:3306 \
	-v /data:/data \
	-v /var/lib/mysql:/var/lib/mysql \
	-e MYSQL_PASS="admin" \
	-e SITE_SAMPLE="create" \
	--name=lamp \
	lamp:latest

Container launching (with sample site erase if allready exists in /data dir of host machine)

	sudo docker run -d -p 80:80 -p 3306:3306 \
	-v /data:/data \
	-v /var/lib/mysql:/var/lib/mysql \
	-e MYSQL_PASS="admin" \
	-e SITE_SAMPLE="erase" \
	--name=lamp \
	lamp:latest


# Usage for diem's site sample

## Launch container

Create local datas. Create host directories.

    mkdir /data 
    mkdir /data/lamp 
    mkdir /data/lamp/conf 
    mkdir /data/lamp/www 
    mkdir /data/gitlibs/
    mkdir /data/gitlibs/diem
    cd /data/gitlibs/diem
    git clone https://github.com/SidPresse/diem.git

Directory */data/lamp/conf* contains apache conf files for each site
Directory */data/lamp/www* contains site's source's file

Container launching
	
    sudo docker run -d -p 80:80 -p 3306:3306 \
    -v /data:/data \
    -v /var/lib/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --name=lamp \
    --add-host=vm20.local:91.194.100.247 \
    lamp:latest

Alternative launching with added hosts for container. Needed for install a diem site

    sudo docker run -d -p 80:80 -p 3306:3306 \
    -v /data:/data \
    -v /var/lib/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --name=lamp \
    --add-host=sitediem.loc:127.0.0.1 \
    --add-host=sitediem2.loc:127.0.0.1 \
    --add-host=sitediem3.loc:127.0.0.1 \
    --add-host=vm20.local:91.194.100.247 \
    lamp:latest

## Access container in CLI

Command line access of previous container

    sudo docker exec -it lamp bash

## Install diem site

Into CLI of container to install a new diem site:

Create directory of site into /data/lamp/www/
Into this dir launch 

    php /data/lamp/lib/dien/install

Etc...

## Erase container

    sudo docker rm -f lamp

## Apache2 controls

See status
	
	apachectl status
	apachectl configtest


## Xdebug usage
Install package Xdebug

	apt-get -y install php5-xdebug
    find / -name 'xdebug.so' 2> /dev/null
    
Add extension to php.ini

    echo 'zend_extension="/usr/lib/php5/20131226/xdebug.so"' >> /etc/php5/apache2/php.ini 
    apachectl restart
    
If needed

    echo 'xdebug.max_nesting_level = 1000' >> /etc/php5/apache2/php.ini 
    apachectl restart








