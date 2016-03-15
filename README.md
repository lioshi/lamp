<!-- MarkdownTOC -->

- [Lamp](#lamp)
- [Usage for site sample](#usage-for-site-sample)
    - [Launch container](#launch-container)
- [Usage for diem's site sample](#usage-for-diems-site-sample)
    - [Launch container](#launch-container-1)
    - [Access container in CLI](#access-container-in-cli)
    - [Install diem site](#install-diem-site)
    - [Erase container](#erase-container)
    - [Apache2 controls](#apache2-controls)
    - [PhpMyAdmin access](#phpmyadmin-access)
    - [Xdebug usage](#xdebug-usage)
- [Usage for install testa's site](#usage-for-install-testas-site)
    - [Elasticsearch install](#elasticsearch-install)
        - [launch previously "lioshi/elasticsearch" image with directory in host to persist elasticsearch indexations](#launch-previously-lioshielasticsearch-image-with-directory-in-host-to-persist-elasticsearch-indexations)
        - [And then launch "lioshi/lamp" image with link](#and-then-launch-lioshilamp-image-with-link)
        - [Access lamp container](#access-lamp-container)
        - [the first time run, into testa dir](#the-first-time-run-into-testa-dir)
    - [Testa install](#testa-install)
    - [Déployer le site](#déployer-le-site)
- [Linux usage](#linux-usage)
    - [Launch image for diem's sites](#launch-image-for-diems-sites)
        - [Without remove lamp container](#without-remove-lamp-container)
    - [Launch image for testa site](#launch-image-for-testa-site)
    - [Some commands](#some-commands)
    - [Mysql Workbench usage](#mysql-workbench-usage)
- [Mac OSX / Windows usage](#mac-osx--windows-usage)
    - [Launch image for diem's sites with data volume (TO BE TESTED)](#launch-image-for-diems-sites-with-data-volume-to-be-tested)
    - [Launch image for diem's sites (WORKED, normaly)](#launch-image-for-diems-sites-worked-normaly)

<!-- /MarkdownTOC -->


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

On Mac OSX : the host Ip will be the IP you will be given when you'll start the Docker Quickstart terminal (IP of the "default" machine)

Run docker service

	sudo service docker start

Container launching (with sample site create)

	sudo docker run --privileged=true -d -p 80:80 -p 3306:3306 \
	-v /data:/data \
	-v /var/lib/mysql:/var/lib/mysql \
	-e MYSQL_PASS="admin" \
	-e SITE_SAMPLE="create" \
	--name=lamp \
	lioshi/lamp:latest

Container launching (with sample site erase if allready exists in /data dir of host machine)

	sudo docker run --privileged=true -d -p 80:80 -p 3306:3306 \
	-v /data:/data \
	-v /var/lib/mysql:/var/lib/mysql \
	-e MYSQL_PASS="admin" \
	-e SITE_SAMPLE="erase" \
	--name=lamp \
	lioshi/lamp:latest


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
	
    sudo docker run --privileged=true -d -p 80:80 -p 3306:3306 \
    -v /data:/data \
    -v /var/lib/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --name=lamp \
    --add-host=vm20.local:91.194.100.247 \
    lioshi/lamp:latest

Alternative launching with added hosts for container. Needed for install a diem site

    sudo docker run --privileged=true -d -p 80:80 -p 3306:3306 \
    -v /data:/data \
    -v /var/lib/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --name=lamp \
    --add-host=sitediem.loc:127.0.0.1 \
    --add-host=sitediem2.loc:127.0.0.1 \
    --add-host=sitediem3.loc:127.0.0.1 \
    --add-host=vm20.local:91.194.100.247 \
    lioshi/lamp:latest

## Access container in CLI

Command line access of previous container

    sudo docker exec -it lamp bash

## Install diem site

Into CLI of container to install a new diem site:

Create directory of site into /data/lamp/www/
Into this dir launch 

    php /data/lamp/lib/dien/install

Etc...

Sample for an sitediem2.loc site

    mkdir /data/lamp/www/sitediem2 && \
    cd /data/lamp/www/sitediem2 && \
    php /data/gitlibs/diem/install && \
    php /data/lamp/www/sitediem2/symfony theme:install && \
    php /data/lamp/www/sitediem2/symfony db:loadDB && \
    php /data/lamp/www/sitediem2/symfony less:compile-all

## Erase container

    sudo docker rm -f lamp

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
    apachectl restart
    
If needed

    echo 'xdebug.max_nesting_level = 1000' >> /etc/php5/apache2/php.ini 
    apachectl restart



# Usage for install testa's site

## Elasticsearch install

Container launching (with ElasticSearch link, for testa application usage)

### launch previously "lioshi/elasticsearch" image with directory in host to persist elasticsearch indexations

    sudo docker run --privileged=true -d -p 9200:9200 -p 9300:9300 \
    -v /data/elasticsearch:/usr/share/elasticsearch/data \
    --name=elasticsearch \
    lioshi/elasticsearch

### And then launch "lioshi/lamp" image with link

    sudo docker run --privileged=true -d -p 80:80 -p 3306:3306 \
    -v /data:/data \
    -v /var/lib/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --link elasticsearch \
    --name=lamp \
    lioshi/lamp:latest

NB: for information the link *elasticsearch* is used into config.yml file into testa : 
    
    fos_elastica:
        clients:
            default: { host: elasticsearch, port: 9200 }

### Access lamp container

    sudo docker exec -it lamp bash

### the first time run, into testa dir

    php app/console fos:elastica:populate 

## Testa install

Créer un fichier de conf apache dans le dossier /data/lamp/conf de l'hôte

    <VirtualHost *:80>
      ServerName    testa.loc
      DocumentRoot  /data/lamp/www/testa/web
      AddType         application/x-httpd-php .php
      DirectoryIndex  app.php
    <Directory /data/lamp/www/testa/web>
    <IfModule mod_rewrite.c>
        RewriteEngine On
        #<IfModule mod_vhost_alias.c>
        #    RewriteBase /
        #</IfModule>
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ app.php [QSA,L]
    </IfModule>
    </Directory>
    </VirtualHost>      

Et ajouter dans le /etc/hosts de l'hôte

    127.0.0.1   testa.loc

Cloner https://github.com/SidPresse/testa.git (ou un fork si vous n'avez pas accès) dans le dossier /data/lamp/www de l'hôte

    cd /data/lamp/www
    git clone https://github.com/SidPresse/testa.git

Créer le fichier composer.json à l'image de composer.json.dist

    cp /data/lamp/www/testa/composer.json.dist /data/lamp/www/testa/composer.json

Dupliquer le fichier parameters.yml sur l'hôte

    cp /data/lamp/www/testa/app/config/parameters.yml.dist /data/lamp/www/testa/app/config/parameters.yml

Lancer à la racine du projet un

    composer update

NB: Composer va demander un token pour l'accès à certains repo privés, suivez les directives de composer.


Si problème de config avec composer update, ou alors pour gagner du temps car le composer update demande beaucoup de temps pour "puller" tous les vendors nécessaires de packagist:

    cat vendor.tar.gz-* > vendor.tar.gz
    tar -xzvf vendor.tar.gz

Mettra une version qui fonctionne (en date du fichier) de tous les vendors nécessaires. Un `composer update` peut être lancé ensuite, il sera plus rapide.

Pour remmettre dans le repo une archive de vendors (decoupee en fichier de 50mo: limite de github) à jour:

    split -b 50000k vendors.tar.gz


## Déployer le site

On crée la base de données

    php app/console doctrine:database:create
    php app/console doctrine:schema:update --dump-sql
    php app/console doctrine:schema:update --force    // IMPORTANT : pour mettre à jour les entities

Les assets

    php app/console assets:install web --symlink
    php app/console assetic:dump

Purge du cache

    php app/console cache:clear --env=prod
    php app/console cache:clear --no-debug


Création du dossier des médias

    mkdir web/uploads
    mkdir web/uploads/media
    chmod -Rf 777 web/uploads

Créer les dossiers de cache et de log (si besoin)

    mkdir app/cache
    mkdir app/logs

A la racine de votre projet lancer:

    setfacl -R -m u:www-data:rwx -m u:`whoami`:rwx app/cache app/logs
    setfacl -dR -m u:www-data:rwx -m u:`whoami`:rwx app/cache app/logs

Créer un utilisateur super admin

    php app/console fos:user:create admin admin@example.com admin --super-admin

Créer un utilisateur type Web avec peu d'accès

    php app/console fos:user:create web web@example.com web
    php app/console fos:user:promote web ROLE_ADMIN_WEB

Créer le dossier d'import K4

    mkdir /data/import
    mkdir /data/import/_xmlK4Testa
    chmod -R 777 /data/import
    
Mettre quelques articles.xml à l'intérieur

Créer les dossiers utiles 

    mkdir /data/export
    chmod -R 777 /data/export
    mkdir /data/export/_exportTesta
    chmod -R 777 /data/export/_exportTesta
    mkdir /data/export/_exportTesta/_archive
    chmod -R 777 /data/export/_exportTesta/_archive
    mkdir /data/export/_mediasTesta
    chmod -R 777 /data/export/_mediasTesta

Lancer un import des articles

    php app/console testa:import k4 --env=prod 








# Linux usage

## Launch image for diem's sites
    sudo service docker start && \
    sudo docker rm -f lamp && \
    sudo docker run --privileged=true -d -p 80:80 -p 3306:3306 -v /data:/data -v /var/lib/mysql:/var/lib/mysql -e MYSQL_PASS="admin" --name=lamp --add-host=sitediem.loc:127.0.0.1 --add-host=sitediem2.loc:127.0.0.1 --add-host=sitediem3.loc:127.0.0.1 --add-host=vm20.local:91.194.100.247 lioshi/lamp:latest && \
    sudo docker exec -it lamp bash

### Without remove lamp container
    sudo service docker start && \
    sudo docker run --privileged=true -d -p 80:80 -p 3306:3306 -v /data:/data -v /var/lib/mysql:/var/lib/mysql -e MYSQL_PASS="admin" --name=lamp --add-host=sitediem.loc:127.0.0.1 --add-host=sitediem2.loc:127.0.0.1 --add-host=sitediem3.loc:127.0.0.1 --add-host=vm20.local:91.194.100.247 lioshi/lamp:latest && \
    sudo docker exec -it lamp bash

## Launch image for testa site

    sudo service docker start && sudo docker rm -f elasticsearch && sudo docker run --privileged=true -d -p 9200:9200 -p 9300:9300 -v /data/elasticsearch:/usr/share/elasticsearch/data --name=elasticsearch lioshi/elasticsearch

    sudo service docker start && \
    sudo docker rm -f lamp && \
    sudo docker run --privileged=true -d -p 80:80 -p 3306:3306 -v /data:/data -v /var/lib/mysql:/var/lib/mysql -e MYSQL_PASS="admin" --link elasticsearch --name=lamp --add-host=sitediem.loc:127.0.0.1 --add-host=sitediem2.loc:127.0.0.1 --add-host=sitediem3.loc:127.0.0.1 --add-host=vm20.local:91.194.100.247 lioshi/lamp:latest && \
    sudo docker exec -it lamp bash

## Some commands
    docker ps - Lists containers.
    docker logs - Shows us the standard output of a container.
    docker stop - Stops running containers.

## Mysql Workbench usage

    ifconfig docker0 

get IP adresse of docker0
In workbench use this IP and admin user with password choose in docker run -e MYSQL_PASS var 







# Mac OSX / Windows usage

## Launch image for diem's sites with data volume (TO BE TESTED)

	sudo service docker start && \
	sudo docker rm -f lamp && \
	sudo docker run --privileged=true -d -p 80:80 -p 3306:3306 -v /data:/data -v /var/lib/mysql:/var/lib/mysql -e MYSQL_PASS="admin" --name=lamp --add-host=sitediem.loc:127.0.0.1 --add-host=sitediem2.loc:127.0.0.1 --add-host=sitediem3.loc:127.0.0.1 --add-host=vm20.local:91.194.100.247 lioshi/lamp:latest && \
	sudo docker exec -it lamp bash
	


## Launch image for diem's sites (WORKED, normaly)
No persist mysql db via volume host/container possible with restriction of permissions between host -> VM -> container 
Then no persitence with volume used: 
    
    -v /var/lib/mysql:/var/lib/mysql

But use var **MYSQL_PERSIST_BY_CRON** to made a cron launch regulary (every minute) to dump all bases in /data host dir. 
And when image is run then restore all databases if file saved by cron exists.

    -e MYSQL_PERSIST_BY_CRON="yes"

Then launch those commands

    sudo service docker start && \
    sudo docker rm -f lamp && \
    sudo docker run -d -p 80:80 -p 3306:3306 -v /data:/data -e MYSQL_PERSIST_BY_CRON="yes" -e MYSQL_PASS="admin" --name=lamp --add-host=sitediem.loc:127.0.0.1 --add-host=sitediem2.loc:127.0.0.1 --add-host=sitediem3.loc:127.0.0.1 --add-host=vm20.local:91.194.100.247 lioshi/lamp:latest && \
    sudo docker exec -it lamp bash

