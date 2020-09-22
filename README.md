LAMP, a Docker image from Debian with LAMP, nodeJs, V8JS, imagick... 

# Image versionning
- lioshi/lamp:php7

Legacy's versions
- lioshi/lamp:latest
- lioshi/lamp:php5
- lioshi/lamp:php5v8js

# Prerequisites

## Install Docker

### Linux 

Run docker service

	sudo service docker start

Add current user to docker's group

    groupadd docker
    sudo usermod -aG docker $USER

### Windows

---
> 🔔 TODO : add WSL 2 installation documenation 🔔
---

## Create sites and repositories directories structure

    mkdir ~/data ~/data/lamp ~/data/lamp/conf ~/data/lamp/www ~/data/mysql ~/data/ssl ~/gitlibs
    
- *~/data/lamp/conf* : apache conf files for each site
- *~/data/lamp/www* : site's source's file
- *~/data/lamp/mysql* : persistence DB 
- *~/data/lamp/ssl* : SSL certificats with mkcert (see below)
- *~/gitlibs* : Git repositories inside

## Local SSL certificats

> source : https://github.com/FiloSottile/mkcert

### Linux

    git clone https://github.com/FiloSottile/mkcert ~/.mkcert
    cd ~/.mkcert
    mkcert -install

> Created a new local CA at "/home/user/.local/share/mkcert" 💥  
> The local CA is now installed in the system trust store! ⚡️  
> The local CA is now installed in the Firefox trust store (requires browser restart)! 🦊

    mkcert "*.site.loc"
    
> Using the local CA at "~/.local/share/mkcert" ✨  
> Created a new certificate valid for the following names 📜  
>      "*.site.loc"  
> The certificate is at "./_wildcard.site.loc.pem" and the key at "./_wildcard.site.loc-key.pem" ✅  

### Windows

---
> 🔔 TODO : add SSL certificat with mkcert installation documentation 🔔
---

# Usage for sample "Hello world"
Add in your /etc/hosts file

	127.0.0.1   site.loc 

Launch container

	docker run -d -p 80:80 -p 443:443 -p 3306:3306 \
	-v ~/data:/data \
	-v ~/data/mysql:/var/lib/mysql \
	-e MYSQL_PASS="admin" \
	-e SITE_SAMPLE="create" \
	--name=lamp \
	lioshi/lamp:php7

If http://site.loc works then remove it by launching

	docker run -d -p 80:80 -p 443:443 -p 3306:3306 \
	-v ~/data:/data \
	-v ~/data/mysql:/var/lib/mysql \
	-e MYSQL_PASS="admin" \
	-e SITE_SAMPLE="erase" \
	--name=lamp \
	lioshi/lamp:php7

# Usage for diem's site 
## Clone Diem repository

    git clone https://gitlab.dev.eilep.com/lesechos/diem.git ~/gitlibs/diem
    cd ~/gitlibs/diem
    git submodule update --init --recursive

## Launch container

    docker run -d -p 80:80 -p 443:443 -p 3306:3306  \
    -v ~/data:/data \
    -v ~/.mkcert:/ssl \
    -v ~/data/mysql:/var/lib/mysql  \
    -v ~/gitlibs:/gitlibs   \
    -e MYSQL_PASS="admin"  \
    --name=lamp  \
    --add-host=diem1.site.loc:127.0.0.1  \
    --add-host=diem2.site.loc:127.0.0.1  \
    --add-host=diem3.site.loc:127.0.0.1  \
    --add-host=diem4.site.loc:127.0.0.1  \
    --add-host=diem5.site.loc:127.0.0.1  \
    --add-host=testa.site.loc:127.0.0.1  \
    --add-host=vm20.local:91.194.100.247  \
    lioshi/lamp:php7 

## Install diem site

    docker exec -it lamp env TERM=xterm bash

*You are now into docker container*

    mkdir /data/lamp/www/diem1
    cd /data/lamp/www/diem1
    php /gitlibs/diem/install
    (...)
    php /data/lamp/www/sitediem2/symfony theme:install && \
    php /data/lamp/www/sitediem2/symfony db:loadDB && \
    php /data/lamp/www/sitediem2/symfony less:compile-all



## Clone a remote site into local docker environment
- On production server
    - Create the dump 
    ```bash
    php /data/www/sitesv3/_site_ec/symfony db:dump --auto=true --envir=2 --compress=true --nameDate=true
    ```
    - Copy filename **/data/www/_sites_dumps/_site_ec/xxx.dump.tar.gz**

- On local machine :
    - Download the dump file from remote server (outside of docker container)
    ```bash
    rsync -chavzP --stats sidpresse@91.XXX.XXX.XXX:"/data/www/_sites_dumps/_site_ec/xxx.dump.tar.gz*" ~/data/lamp/_sites_dumps
    ```
    - Load dump into site (inside the docker container)
    ```bash
    php /data/lamp/www/diem1/symfony db:load /data/lamp/_sites_dumps/xxx.dump.tar.gz
    ```

## Push a dump to remote server
- On local machine :
    - Create the dump (inside the docker container)
    ```bash
    php /data/lamp/www/diem1/symfony db:dump --auto=true --envir=3 --compress=true --nameDate=true
    ```
    - Copy filename path **/data/lamp/_sites_dumps/diem1/xxx.dump.tar.gz**
    - Upload the dump file to remote server (outside of docker container)
    ```bash
    rsync -avH /home/lioshi/data/lamp/_sites_dumps/diem1/xxx.dump.tar.gz* sidpresse@91.XXX.XXX.XXX:/data/www/_sites_dumps/_site_ec
    ```
- On production server
    - Load dump into site 
    ```bash
    php /data/www/sitesv3/_site_ec/symfony db:load /data/lamp/_sites_dumps/_site_ec/xxx.dump.tar.gz
    ```




## Hints
### Docker Container commands
Acces to Docker container
    
    docker exec -it lamp env TERM=xterm bash

Remove Docker container

    docker rm -f lamp

Restart Docker container
    
    docker restart lamp 

Lists containers

    docker ps 

Shows us the standard output of a container.
    
    docker logs

Stops running containers

    docker stop 

### Inside Container commands
Apache2 controls

    apachectl status
    apachectl configtest
    apachectl -S

### PhpMyAdmin access

http://localhost/phpmyadmin

### Xdebug usage
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




# Usage for install testa's site
## Elasticsearch install

Container launching (with ElasticSearch link, for testa application usage)

### launch previously "lioshi/elasticsearch" image with directory in host to persist elasticsearch indexations

    docker run --privileged=true -d -p 9200:9200 -p 9300:9300 \
    -v ~/data/elasticsearch:/usr/share/elasticsearch/data \
    --name=elasticsearch \
    lioshi/elasticsearch

### launch previously "lioshi/memcached" image 

    docker run --name memcached -p 11211:11211 -d lioshi/memcached

### And then launch "lioshi/lamp" image with link

```bash
    docker run --privileged=true -d -p 80:80 -p 443:443 -p 3306:3306 \
    -v ~/data:/data \
    -v ~/.mkcert:/ssl \
    -v ~/data/mysqltesta:/var/lib/mysql \
    -e MYSQL_PASS="admin" \
    --link elasticsearch \
    --link memcached \
    --name=lamp \
    --add-host=testa.site.loc:127.0.0.1  \
    lioshi/lamp:php5

    docker exec -it lamp env TERM=xterm bash
```

NB: for information the link *elasticsearch* is used into config.yml file into testa : 
    
    fos_elastica:
        clients:
            default: { host: elasticsearch, port: 9200 }

### Access lamp container

    docker exec -it lamp env TERM=xterm bash

### the first time run, into testa dir

    php app/console fos:elastica:populate 

## Testa install

Créer un fichier de testa.conf apache dans le dossier ~/data/lamp/conf de l'hôte ou dans le dossier /data/lamp/conf du container bien sûr

```apache
<VirtualHost *:443>
    ServerName    testa.site.loc
    DocumentRoot  /data/lamp/www/testa/web
    <FilesMatch ".php$">
        SetHandler application/x-httpd-php
    </FilesMatch>
    DirectoryIndex  app.php

    SSLEngine on
    SSLCertificateFile /ssl/_wildcard.site.loc.pem
    SSLCertificateKeyFile /ssl/_wildcard.site.loc-key.pem

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
```

Et ajouter dans le /etc/hosts de l'hôte

    127.0.0.1   testa.site.loc

Cloner https://github.com/SidPresse/testa.git (ou un fork si vous n'avez pas accès) dans le dossier /data/lamp/www de l'hôte

    cd ~/data/lamp/www
    git clone https://github.com/SidPresse/testa.git

Créer le fichier composer.json à l'image de composer.json.dist

    cp ~/data/lamp/www/testa/composer.json.dist ~/data/lamp/www/testa/composer.json

Dupliquer le fichier parameters.yml sur l'hôte

    cp ~/data/lamp/www/testa/app/config/parameters.yml.dist ~/data/lamp/www/testa/app/config/parameters.yml

Lancer à la racine du projet un

    composer update

NB: Composer va demander un token pour l'accès à certains repo privés, suivez les directives de composer:
Générez un jeton pour vous sur github:  https://github.com/settings/tokens
Nous recevons notre jeton, par exemple: 1234567890abcdef1234567890abcdef123456789
Exécutez la commande dans la console: 
    
    composer config -g github-oauth.github.com  1234567890abcdef1234567890abcdef123456789
    

Si *problème de config avec composer update*, ou alors pour gagner du temps car le composer update demande beaucoup de temps pour "puller" tous les vendors nécessaires de packagist:

    cat vendors.tar.gz-* > vendors.tar.gz
    tar -xzvf vendors.tar.gz

Mettra une version qui fonctionne (en date du fichier) de tous les vendors nécessaires. Un `composer update` peut être lancé ensuite, il sera plus rapide.

Pour remmettre dans le repo git une archive de vendors (decoupee en fichier de 50mo: limite de github) à jour:

    split -b 50000k vendors.tar.gz


## Déployer le site

On crée la base de données

```bash
    php app/console doctrine:database:create
    php app/console doctrine:schema:update --dump-sql
    php app/console doctrine:schema:update --force    # IMPORTANT : pour mettre à jour les entities
```
Les assets

```bash
    php app/console assets:install web --symlink
    php app/console assetic:dump
```

Purge du cache

```bash
    php app/console cache:clear --env=prod
    php app/console cache:clear --no-debug
```

Création du dossier des médias

```bash
    mkdir web/uploads
    mkdir web/uploads/media
    chmod -Rf 777 web/uploads
```

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

Lancer le populate d'elasticSearch

    php app/console fos:elastica:populate --env=prod

## Restart containers
    docker restart elasticsearch & docker restart memcached & docker restart lamp





# Development
## Build image
In root directory of repo

    docker build --tag="lamp:php7" .  

## legacy versions

    docker build --tag="lamp:latest" .    
    docker build -f Dockerfile-php5 --tag="lamp:php5" . 
    docker build -f Dockerfile-php5v8js --tag="lamp:php5v8js" .
 
## Push local image into dockerhub
- Create tag
```bash    
docker tag lamp:latest lioshi/lamp:php7
```
- Connect to docker hub from CLI
```bash
docker login --username=lioshi 
```
- Push local image into dockerhub
```bash
docker push lioshi/lamp:php7
```

# Miscellanous
## Mysql Workbench usage

    ifconfig docker0 

get IP adresse of docker0
In workbench use this IP and admin user with password choose in docker run -e MYSQL_PASS var 

