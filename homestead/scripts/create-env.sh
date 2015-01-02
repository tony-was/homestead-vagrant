#!/usr/bin/env bash

DIR="/home/vagrant/sites/$1.dev"

echo ".env creation script for $1"

if [ ! -d "$DIR" ]; then
    echo "$DIR not found. Creating $DIR"
    mkdir $DIR
fi

if [ ! -f $DIR/.env ]; then
    echo ".env file not found. Creating .env file in $DIR"
cat >$DIR/.env <<EOL
APP_ENV=development
DB_HOST=localhost
DB_DATABASE=myjointpain
DB_USERNAME=homestead
DB_PASSWORD=secret
EOL
else
    echo ".env file already exists in $DIR"
fi