#!/usr/bin/env bash

NAME=$1
NAME_EXT="$NAME.dev"
DIR="/home/vagrant/sites/$NAME_EXT"

if [ ! -d "$DIR" ]; then
    echo "$DIR not found. Creating $DIR"
    mkdir $DIR
fi

if [ -f $DIR/composer.json ]; then
    echo "Running composer update for $NAME"
    cd $DIR
    composer self-update
    composer update --no-interaction --quiet --optimize-autoloader
else
    echo "Not composer.json found for $NAME"
fi