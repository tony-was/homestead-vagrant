#!/usr/bin/env bash

DIR="/home/vagrant/sites/$1.dev"

echo "Project creation script for $1"

if [ ! -d "$DIR" ]; then
    echo "$DIR not found. Creating $DIR"
    mkdir $DIR
fi

if [ "$(ls -A $DIR)" ]; then
     echo "$DIR already has established project"
else
    echo "Cloning project into $DIR"
    cd $DIR
    git clone https://github.com/tony-was/laravel-base.git .
    rm -rf .git
fi