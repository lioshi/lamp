<!-- MarkdownTOC -->

- [Lamp](#lamp)
- [Versions](#versions)
- [Usage for site sample](#usage-for-site-sample)
    - [Launch container](#launch-container)
- [Usage for diem's site sample](#usage-for-diems-site-sample)
    - [Launch container](#launch-container)
    - [Access container in CLI](#access-container-in-cli)
    - [Install diem site](#install-diem-site)
    - [Erase container](#erase-container)
    - [Restart a docker container](#restart-a-docker-container)
    - [Apache2 controls](#apache2-controls)
    - [PhpMyAdmin access](#phpmyadmin-access)
    - [Xdebug usage](#xdebug-usage)
- [Usage for install testa's site](#usage-for-install-testas-site)
    - [Elasticsearch install](#elasticsearch-install)
        - [launch previously "lioshi/elasticsearch" image with directory in host to persist elasticsearch indexations](#launch-previously-lioshielasticsearch-image-with-directory-in-host-to-persist-elasticsearch-indexations)
        - [launch previously "lioshi/memcached" image](#launch-previously-lioshimemcached-image)
        - [And then launch "lioshi/lamp" image with link](#and-then-launch-lioshilamp-image-with-link)
        - [Access lamp container](#access-lamp-container)
        - [the first time run, into testa dir](#the-first-time-run-into-testa-dir)
    - [Testa install](#testa-install)
    - [Déployer le site](#d%C3%A9ployer-le-site)
- [Linux usage](#linux-usage)
    - [Restart containers](#restart-containers)
    - [Launch image for diem's sites](#launch-image-for-diems-sites)
    - [Launch image for testa site](#launch-image-for-testa-site)
    - [Some commands](#some-commands)
    - [Mysql Workbench usage](#mysql-workbench-usage)
- [Mac OSX / Windows usage](#mac-osx-windows-usage)
    - [Launch image for diem's sites with data volume (TO BE TESTED)](#launch-image-for-diems-sites-with-data-volume-to-be-tested)
    - [Launch image for diem's sites (WORKED, normaly)](#launch-image-for-diems-sites-worked-normaly)

<!-- /MarkdownTOC -->


# Lamp
Docker image for diem sites. Debian with LAMP, nodeJs, imagick... etc


# Versions
ATTENTION: master/latest: PHP 7 version
Call version you prefer in run command:

- lioshi/lamp:latest
- lioshi/lamp:php5
- lioshi/lamp:php5v8js

This docker image is used to launch container with all necessary applicatives instances for diem CMF

- Debian
- Apache
- PHP 5 or 7
- Mysql 
- Node
- ImageMagick
- NodeJs
- V8JS or not
- etc ...

# Usage for site sample

## Launch container

Create local datas. Create host directories.

    mkdir /home/lioshi/data 
    mkdir /home/lioshi/data/lamp 
    mkdir /home/lioshi/data/lamp/conf 
    mkdir /home/lioshi/data/lamp/www 
    mkdir /home/lioshi/data/mysql
    
Directory */home/lioshi/data/lamp/conf* contains apache conf files for each site

Directory */home/lioshi/data/lamp/www* contains site's source's file

Add host locally (in your /etc/hosts file)

	127.0.0.1   site.loc 

On Mac OSX : the host Ip will be the IP you will be given when you'll start the Docker Quickstart terminal (IP of the "default" machine)

Install Docker on Debian stretch

    sudo apt-get install apt-transport-https dirmngr
    su -
    
En root:

    echo 'deb https://apt.dockerproject.org/repo debian-stretch main' >> /etc/apt/sources.list
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys F76221572C52609D
    exit

En user

    sudo apt-get update
    sudo apt-get install docker-engine
    docker -v
    sudo service docker start
    sudo groupadd docker
    sudo usermod -aG docker $USER

Run docker service

	sudo service docker start

Ajouter user au group docker

    groupadd docker
    sudo usermod -aG docker $USER
    exit   

clone lioshi/lamp repo

    cd /home/lioshi/gitlibs/
    git clone https://github.com/lioshi/lamp.git

### Build (if needed)
Build image LAMP for version you need, in root of repo LAMP directory

    docker build --tag="lamp:latest" .    
    docker build -f Dockerfile-php5 --tag="lamp:php5" . 
    (optional) docker build -f Dockerfile-php5v8js --tag="lamp:php5v8js" .
 
Push local image into hubdocker
- Create tag
    >>> docker tag lamp:latest lioshi/lamp:latest
- Connect to docker hub from CLI
    >>> docker login --username=lioshi --email=lionel.fenneteau@gmail.com
- Push local image into dockerhub
    >>> docker push lioshi/lamp:latest

Container launching (with sample site create)

	docker run --privileged=true -d -p 80:80 -p 443:443 -p 3306:3306 \
	-v /home/lioshi/data:/data \
	-v /home/lioshi/data/mysql:/var/lib/mysql \
	-e MYSQL_PASS="admin" \
	-e SITE_SAMPLE="create" \
	--name=lamp \
	lioshi/lamp:latest

Container launching (with sample site erase if allready exists in /home/lioshi/data dir of host machine)

	docker run --privileged=true -d -p 80:80 -p 443:443 -p 3306:3306 \
	-v /home/lioshi/data:/data \
	-v /home/lioshi/data/mysql:/var/lib/mysql \
	-e MYSQL_PASS="admin" \
	-e SITE_SAMPLE="erase" \
	--name=lamp \
	lioshi/lamp:latest


# Usage for diem's site sample

## Launch container

Create local datas. Create host directories.

    mkdir /home/lioshi/data 
    mkdir /home/lioshi/data/lamp 
    mkdir /home/lioshi/data/lamp/conf 
    mkdir /home/lioshi/data/lamp/www 
    mkdir /home/lioshi/data/gitlibs/
    git clone https://github.com/SidPresse/diem.git
    cd /home/lioshi/data/gitlibs/diem
    git submodule update --init --recursive

Directory */home/lioshi/data/lamp/conf* contains apache conf files for each site
Directory */home/lioshi/data/lamp/www* contains site's source's file

Container launching
	
    docker run --privileged=true -d -p 80:80 -p 443:443 -p 3306:3306 \
    -v /home/lioshi/data:/data \
    -v /home/lioshi/data/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --name=lamp \
    --add-host=vm20.local:91.194.100.247 \
    lioshi/lamp:latest

Alternative launching with added hosts for container. Needed for install a diem site

    docker run --privileged=true -d -p 80:80 -p 443:443 -p 3306:3306 \
    -v /home/lioshi/data:/data \
    -v /home/lioshi/gitlibs:/gitlibs \
    -v /home/lioshi/data/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --name=lamp \
    --add-host=sitediem.loc:127.0.0.1 \
    --add-host=sitediem2.loc:127.0.0.1 \
    --add-host=sitediem3.loc:127.0.0.1 \
    --add-host=vm20.local:91.194.100.247 \
    lioshi/lamp:latest

## Access container in CLI

Command line access of previous container

    docker exec -it lamp env TERM=xterm bash

## Install diem site

*You are now into docker container*
Into CLI of container to install a new diem site:

Create directory of site into /data/lamp/www/
Into this dir launch your local diem, example:

    php /data/lamp/lib/diem/install

Etc...

Sample for an sitediem2.loc site

    mkdir /data/lamp/www/sitediem2 && \
    cd /data/lamp/www/sitediem2 && \
    php /data/gitlibs/diem/install && \
    php /data/lamp/www/sitediem2/symfony theme:install && \
    php /data/lamp/www/sitediem2/symfony db:loadDB && \
    php /data/lamp/www/sitediem2/symfony less:compile-all

## Erase container
    docker rm -f lamp

## Restart a docker container
    docker restart lamp 

## Apache2 controls

See status
	
    apachectl status
    apachectl configtest

## PhpMyAdmin access

http://localhost/phpmyadmin

## Xdebug usage
Install package Xdebug

    apt-get -y install php5-xdebug
    find / -name 'xdebug.so' 2> /dev/null
    
Add extension to php.ini

    echo 'zend_extension="/usr/lib/php5/20131226/xdebug.so"' >> /etc/php5/apache2/php.ini 
    echo 'display_errors = On' >> /etc/php5/apache2/php.ini 
    echo 'html_errors = On' >> /etc/php5/apache2/php.ini 
    apachectl restart
    
If needed

    echo 'xdebug.max_nesting_level = 1000' >> /etc/php5/apache2/php.ini 
    echo 'xdebug.profiler_enable = 1' >> /etc/php5/apache2/php.ini
    echo 'xdebug.profiler_output_name = xdebug.out.%t' >> /etc/php5/apache2/php.ini
    echo 'xdebug.profiler_output_dir = /data' >> /etc/php5/apache2/php.ini
    echo 'xdebug.profiler_enable_trigger = 1' >> /etc/php5/apache2/php.ini
    apachectl restart



# Linux usage
    sudo service docker start


## Restart containers
    docker restart elasticsearch & docker restart memcached2 & docker restart lamp

## Launch image for diem's sites
    docker run --privileged=true -d -p 80:80 -p 443:443 -p 3306:3306 -v /home/lioshi/data:/data -v /home/lioshi/gitlibs:/gitlibs -v /home/lioshi/data/mysql:/var/lib/mysql -e MYSQL_PASS="admin" --name=lamp --add-host=sitediem1.loc:127.0.0.1 --add-host=sitediem2.loc:127.0.0.1 --add-host=sitediem3.loc:127.0.0.1 --add-host=sitediem4.loc:127.0.0.1 --add-host=sitediem5.loc:127.0.0.1 --add-host=sitediem6.loc:127.0.0.1 --add-host=sitediem7.loc:127.0.0.1 --add-host=sitediem8.loc:127.0.0.1 --add-host=sitediem9.loc:127.0.0.1 --add-host=vm20.local:91.194.100.247 lioshi/lamp:latest

    docker exec -it lamp env TERM=xterm bash

## Some commands
    docker ps - Lists containers.
    docker logs - Shows us the standard output of a container.
    docker stop - Stops running containers.

## Mysql Workbench usage

    ifconfig docker0 

get IP adresse of docker0
In workbench use this IP and admin user with password choose in docker run -e MYSQL_PASS var 




