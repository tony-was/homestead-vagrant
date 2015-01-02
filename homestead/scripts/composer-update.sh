#!/usr/bin/env bash

DIR="/home/vagrant/sites/$1.dev"

echo "Composer update script for $1"

if [ ! -d "$DIR" ]; then
    echo "$DIR not found. Creating $DIR"
    mkdir $DIR
fi

if [ "$(ls -A $DIR)" ]; then
    echo "Running composer update in $DIR"
    cd $DIR
    composer update
else
    echo "No project in $DIR"
fi