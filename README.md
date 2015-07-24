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

Run docker service

	sudo service docker start

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

    127.0.0.1   sf2.loc

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


Déployer le site

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
    chmod -R 777 /data/import
    mkdir /data/import/_xmlK4Testa
    
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



