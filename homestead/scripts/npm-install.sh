#!/usr/bin/env bash

DIR="/home/vagrant/sites/$1.dev"

echo "npm install script for $1"

if [ ! -d "$DIR" ]; then
    echo "$DIR not found. Cannot run npm install"
    mkdir $DIR
else
     echo "Running npm install in $DIR"
     cd $DIR
     npm install
fi