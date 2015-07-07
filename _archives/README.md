# Docker-diem
Docker image for diem sites. Debian with LAMP, nodeJs, imagick... etc

This docker image is used to launch container with all necessary applicatives instances for diem CMF

- Debian
- Apache
- PHP
- Mysql 
- Node
- ImageMagick
- NodeJs
- Etc ...

## Launch container

Create local datas. Create host directories.

    mkdir /data 
    mkdir /data/docker-diem 
    mkdir /data/docker-diem/conf 
    mkdir /data/docker-diem/www 
    mkdir /data/docker-diem/lib 
    git clone https://github.com/SidPresse/diem.git

Directory */data/docker-diem/conf* contains apache conf files for each site
Directory */data/docker-diem/www* contains site's source's file
Directory */data/docker-diem/lib* contains external libs, diem's lib needed

Container launching
	
    sudo docker run -d -p 80:80 -p 3306:3306 \
    -v /data:/data \
    -v /var/lib/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --name=docker-diem \
    docker-diem:latest

Alternative launching with added hosts for container. Needed for install a diem site

    sudo docker run -d -p 80:80 -p 3306:3306 \
    -v /data:/data \
    -v /var/lib/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --name=docker-diem \
    --add-host=sitediem.loc:127.0.0.1 \
    --add-host=sitediem2.loc:127.0.0.1 \
    --add-host=sitediem3.loc:127.0.0.1 \
    docker-diem:latest

## Access container in CLI

Command line access of previous container

    sudo docker exec -it docker-diem bash

## Install diem site

Into CLI of container to install a new diem site:

Create directory of site into /data/docker-diem/www/
Into this dir launch 

    php /data/docker-diem/lib/dien/install

Etc...

## Erase container

    sudo docker rm -f docker-diem

## Apache2 controls

See status
	
	apachectl status
	apachectl configtest


# Infos docker
## Create Dockerfile in github

See https://github.com/lioshi/docker-diem

## Automatic build image

créer image: https://www.wanadev.fr/docker-vivre-avec-une-baleine-partie-2/
interactive build image : http://www.projectatomic.io/docs/docker-building-images/




