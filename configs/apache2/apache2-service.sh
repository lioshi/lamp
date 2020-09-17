#!/bin/bash

source /etc/apache2/envvars
exec gpasswd -a www-data root
exec apache2 -D FOREGROUND
