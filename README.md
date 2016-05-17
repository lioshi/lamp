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
        - [launch previously "lioshi/memcached" image](#launch-previously-lioshimemcached-image)
        - [And then launch "lioshi/lamp" image with link](#and-then-launch-lioshilamp-image-with-link)
        - [Access lamp container](#access-lamp-container)
        - [the first time run, into testa dir](#the-first-time-run-into-testa-dir)
    - [Testa install](#testa-install)
    - [Déployer le site](#déployer-le-site)
- [Linux usage](#linux-usage)
    - [Launch image for diem's sites](#launch-image-for-diems-sites)
    - [Launch image for testa site](#launch-image-for-testa-site)
    - [Some commands](#some-commands)
    - [Mysql Workbench usage](#mysql-workbench-usage)
- [Mac OSX / Windows usage](#mac-osx--windows-usage)
    - [Launch image for diem's sites with data volume \(TO BE TESTED\)](#launch-image-for-diems-sites-with-data-volume-to-be-tested)
    - [Launch image for diem's sites \(WORKED, normaly\)](#launch-image-for-diems-sites-worked-normaly)

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

Ajouter user au group docker

    groupadd docker
    sudo usermod -aG docker $USER
    exit    

Container launching (with sample site create)

	docker run --privileged=true -d -p 80:80 -p 3306:3306 \
	-v /data:/data \
	-v /var/lib/mysql:/var/lib/mysql \
	-e MYSQL_PASS="admin" \
	-e SITE_SAMPLE="create" \
	--name=lamp \
	lioshi/lamp:latest

Container launching (with sample site erase if allready exists in /data dir of host machine)

	docker run --privileged=true -d -p 80:80 -p 3306:3306 \
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
	
    docker run --privileged=true -d -p 80:80 -p 3306:3306 \
    -v /data:/data \
    -v /var/lib/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --name=lamp \
    --add-host=vm20.local:91.194.100.247 \
    lioshi/lamp:latest

Alternative launching with added hosts for container. Needed for install a diem site

    docker run --privileged=true -d -p 80:80 -p 3306:3306 \
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

    docker exec -it lamp bash

## Install diem site

Into CLI of container to install a new diem site:

Create directory of site into /data/lamp/www/
Into this dir launch your local diem, example:

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

    docker rm -f lamp

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

    docker run --privileged=true -d -p 9200:9200 -p 9300:9300 \
    -v /data/elasticsearch:/usr/share/elasticsearch/data \
    --name=elasticsearch \
    lioshi/elasticsearch

### launch previously "lioshi/memcached" image 

    docker run --name memcached -p 11211:11211 -d lioshi/memcached

### And then launch "lioshi/lamp" image with link

    docker run --privileged=true -d -p 80:80 -p 3306:3306 \
    -v /data:/data \
    -v /var/lib/mysql:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --link elasticsearch \
    --link memcached:memcached \
    --name=lamp \
    lioshi/lamp:latest

    docker exec -it lamp bash

NB: for information the link *elasticsearch* is used into config.yml file into testa : 
    
    fos_elastica:
        clients:
            default: { host: elasticsearch, port: 9200 }

### Access lamp container

    docker exec -it lamp bash

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
        
    # Add correct content-type for fonts
    AddType application/vnd.ms-fontobject .eot
    AddType application/x-font-ttf .ttf
    AddType application/x-font-opentype .otf
    AddType application/x-font-woff .woff
    AddType image/svg+xml .svg
    
    # add deflate
    <IfModule mod_deflate.c>
      # compress text, html, javascript, css, xml:
      AddOutputFilterByType DEFLATE text/plain
      AddOutputFilterByType DEFLATE text/html
      AddOutputFilterByType DEFLATE text/xml
      AddOutputFilterByType DEFLATE text/css
      AddOutputFilterByType DEFLATE application/xml
      AddOutputFilterByType DEFLATE application/xhtml+xml
      AddOutputFilterByType DEFLATE application/rss+xml
      AddOutputFilterByType DEFLATE application/javascript
      AddOutputFilterByType DEFLATE application/x-javascript
      # Compress compressible fonts
      AddOutputFilterByType DEFLATE application/x-font-ttf application/x-font-opentype image/svg+xml
    </IfModule>
    
    # Add expiration dates to static content
    # sudo a2enmod expires && sudo apache2ctl restart
    <IfModule mod_expires.c>
      ExpiresActive On
      ExpiresByType image/gif "access plus 1 year"
      ExpiresByType image/png "access plus 1 year"
      ExpiresByType image/jpg "access plus 1 year"
      ExpiresByType image/jpeg "access plus 1 year"
      ExpiresByType image/png "access plus 1 year"
      ExpiresByType image/x-icon "access plus 1 year"
      ExpiresByType image/svg+xml "access plus 1 year"  
      ExpiresByType text/css "access plus 1 year"
      ExpiresByType text/javascript "access plus 1 year"
      ExpiresByType application/x-Shockwave-Flash "access plus 1 year"
      ExpiresByType application/vnd.ms-fontobject "access plus 1 year"
      ExpiresByType application/x-font-ttf "access plus 1 year"
      ExpiresByType application/x-font-opentype "access plus 1 year"
      ExpiresByType application/x-font-woff "access plus 1 year"
    </IfModule>
    
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

    cat vendors.tar.gz-* > vendors.tar.gz
    tar -xzvf vendors.tar.gz

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

    sudo service docker start

## Launch image for diem's sites
    docker run --privileged=true -d -p 80:80 -p 3306:3306 -v /data:/data -v /var/lib/mysql:/var/lib/mysql -e MYSQL_PASS="admin" --name=lamp --add-host=sitediem1.loc:127.0.0.1 --add-host=sitediem2.loc:127.0.0.1 --add-host=sitediem3.loc:127.0.0.1 --add-host=sitediem4.loc:127.0.0.1 --add-host=sitediem5.loc:127.0.0.1 --add-host=sitediem6.loc:127.0.0.1 --add-host=sitediem7.loc:127.0.0.1 --add-host=sitediem8.loc:127.0.0.1 --add-host=sitediem9.loc:127.0.0.1 --add-host=vm20.local:91.194.100.247 lioshi/lamp:latest

    docker exec -it lamp bash

## Launch image for testa site

    docker run --privileged=true -d -p 9200:9200 -p 9300:9300 -v /data/elasticsearch:/usr/share/elasticsearch/data --name=elasticsearch lioshi/elasticsearch

    docker run --name memcached -p 11211:11211 -d lioshi/memcached

    docker run --privileged=true -d -p 80:80 -p 3306:3306 -v /data:/data -v /var/lib/mysql:/var/lib/mysql -e MYSQL_PASS="admin" --link elasticsearch --link memcached --name=lamp --add-host=sitediem.loc:127.0.0.1 --add-host=sitediem2.loc:127.0.0.1 --add-host=sitediem3.loc:127.0.0.1 --add-host=vm20.local:91.194.100.247 lioshi/lamp:latest

    docker exec -it lamp bash

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
	docker rm -f lamp && \
	docker run --privileged=true -d -p 80:80 -p 3306:3306 -v /data:/data -v /var/lib/mysql:/var/lib/mysql -e MYSQL_PASS="admin" --name=lamp --add-host=sitediem.loc:127.0.0.1 --add-host=sitediem2.loc:127.0.0.1 --add-host=sitediem3.loc:127.0.0.1 --add-host=vm20.local:91.194.100.247 lioshi/lamp:latest && \
	docker exec -it lamp bash
	


## Launch image for diem's sites (WORKED, normaly)
No persist mysql db via volume host/container possible with restriction of permissions between host -> VM -> container 
Then no persitence with volume used: 
    
    -v /var/lib/mysql:/var/lib/mysql

But use var **MYSQL_PERSIST_BY_CRON** to made a cron launch regulary (every minute) to dump all bases in /data host dir. 
And when image is run then restore all databases if file saved by cron exists.

    -e MYSQL_PERSIST_BY_CRON="yes"

Then launch those commands

    sudo service docker start && \
    docker rm -f lamp && \
    docker run -d -p 80:80 -p 3306:3306 -v /data:/data -e MYSQL_PERSIST_BY_CRON="yes" -e MYSQL_PASS="admin" --name=lamp --add-host=sitediem.loc:127.0.0.1 --add-host=sitediem2.loc:127.0.0.1 --add-host=sitediem3.loc:127.0.0.1 --add-host=vm20.local:91.194.100.247 lioshi/lamp:latest && \
    docker exec -it lamp bash

