#!/bin/bash

#root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd "$(dirname "$0")"

#load env variables
source ./env.sh

#check if nginx is running
DOCKER_STOPPED=false
if [ "$(docker ps -aq -f status=running -f name=nginx)" ]; then
    #need to stop temp
    docker container stop nginx
    DOCKER_STOPPED=true
fi

if [ -z "$1" ]
  then
    echo "Please supply the domain name: 'add-domain.sh domain.com'"
    exit 1
fi

docker run --rm -i \
-v "${PERSISTENT_ROOT}/letsencrypt:/etc/letsencrypt" \
-v "${PERSISTENT_ROOT}/certbot:/var/www/certbot" \
-p 80:80 \
-p 443:443 \
certbot/certbot 'certonly' '--standalone' \
"-d $1" '--agree-tos' "-m $LE_EMAIL"

if [ $DOCKER_STOPPED = true ]; then
    docker container start nginx
fi
