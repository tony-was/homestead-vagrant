#!/usr/bin/env bash

NAME=$1
TYPE=$2
REPO=$3
NAME_EXT="$NAME.dev"

case $TYPE in
    ["laravel"]*)
        GIT_REPO="https://github.com/tony-was/laravel-base.git"
    ;;
    ["wordpress"]*)
        GIT_REPO="https://github.com/tony-was/bedrock-was.git"
    ;;
esac

DIR="/home/vagrant/sites/$NAME_EXT"

if [ ! -d "$DIR" ]; then
    echo "Site folder for $NAME not found. Creating..."
    mkdir $DIR
fi

if [ "$(ls -A $DIR)" ]; then
     echo "$NAME is already an established project"
else
    cd $DIR
    if [[ ! -z "$REPO" ]]; then
        echo "Cloning existing $NAME project from repo"
        git clone $REPO .
    else
        echo "Cloning base $TYPE project"
        git clone --depth=1 $GIT_REPO .
        rm -rf .git
    fi
fi

if [ $TYPE == "wordpress" ]; then
    if [ ! -d "$DIR/web/app/themes/roots" ]; then
        echo "Installing roots theme"
        mkdir $DIR/web/app/themes/roots
        cd $DIR/web/app/themes/roots
        git clone --depth=1 https://github.com/tony-was/roots-was.git .
        rm -rf .git
    else
        echo "Roots theme already exists for $NAME"
    fi
fi