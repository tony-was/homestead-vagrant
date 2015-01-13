#!/usr/bin/env bash
NAME=$1
TYPE=$2
NAME_EXT="$NAME.dev"

DIR="/home/vagrant/sites/$NAME_EXT"
case $TYPE in
  'laravel')
  ENV="APP_ENV=development
  DB_HOST=localhost
  DB_DATABASE=$NAME
  DB_USERNAME=homestead
  DB_PASSWORD=secret"
  ;;
  'wordpress')
  ENV="DB_NAME=$NAME
  DB_USER=homestead
  DB_PASSWORD=secret
  DB_HOST=localhost
  WP_ENV=development
  WP_HOME=http://$NAME_EXT
  WP_SITEURL=http://$NAME_EXT/wp"
  ;;
  'drupal')
  ENV="DB_NAME=$NAME
  DB_USER=homestead
  DB_PASSWORD=secret
  DB_HOST=localhost"
  ;;
esac


if [ ! -d "$DIR" ]; then
    echo "$DIR not found. Creating $DIR"
    mkdir $DIR
fi

if [ ! -f $DIR/.env ]; then
    echo ".env file not found. Creating .env file for $NAME"
cat >$DIR/.env <<EOL
$ENV
EOL
else
    echo ".env file already exists for $NAME"
fi
