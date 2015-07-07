# lamp
Docker image for lamp sites. Debian with LAMP, nodeJs, imagick... etc

This docker image is used to launch container with all necessary applicatives instances for diem CMF

- Debian
- Apache
- PHP
- Mysql 
- Node
- ImageMagick
- NodeJs
- Etc ...

##Build image
	sudo docker build --tag="lamp:latest" .

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
	
	docker run -d -p 8000:80 -p 2200:22 -p 3306:3306 \
    -v /data:/var/www/html:rw \
    -v /var/lib/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --name=lamp \
    lamp:latest

Alternative launching with added hosts for container. Needed for install a diem site

    docker run -d -p 8000:80 -p 2200:22 -p 3306:3306 \
    -v /data:/var/www/html:rw \
    -v /var/lib/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --name=lamp \
    --add-host=sitediem.loc:127.0.0.1 \
    --add-host=sitediem2.loc:127.0.0.1 \
    --add-host=sitediem3.loc:127.0.0.1 \
    lamp:latest

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















# Dockie: LAMP

Easily set up and develop on a LAMP stack, using [Dockie Development Environment](http://github.com/robloach/dockie).


## Features

* [Dockie](../dockie)
* [Apache](https://httpd.apache.org/) 2.4.7
* [PHP](http://php.net/) 5.5.9
* [MySQL](http://www.mysql.com/) 5.5.37
* [phpMyAdmin](http://www.phpmyadmin.net/) 4.0.10
* [Composer](http://getcomposer.org) 1.0.0-alpha8


## Usage

### Install

Pull `dockie/lamp` from the Docker repository:
```
docker pull dockie/lamp
```

Or build `dockie/lamp` from source:
```
git clone https://github.com/RobLoach/Dockie.git
cd Dockie
docker build -t dockie/lamp lamp
```

### Run

Run the image, binding associated ports, and mounting the present working
directory:

```
docker run -p 8000:80 -p 2200:22 -p 3306:3306 -v $(pwd):/var/www/html:rw dockie/lamp
```


## Services

### MySQL
Connect on `localhost:3306`, user `root`, password `root`.
