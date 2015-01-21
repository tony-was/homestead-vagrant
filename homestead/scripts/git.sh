#!/usr/bin/env bash

NAME=$1
TYPE=$2
THEME=$3
REPO=$4
NAME_EXT="$NAME.dev"

case $TYPE in
  'laravel')
  GIT_REPO="git@github.com:tony-was/laravel-base.git"
  ;;
  'wordpress')
  GIT_REPO="git@github.com:tony-was/bedrock-was.git"
  ;;
  'drupal')
  GIT_REPO="git@github.com:ryan-was/drupal-base.git"
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
        git clone $REPO . > /dev/null 2>&1
    else
        echo "Cloning base $TYPE project"
        git clone --depth=1 $GIT_REPO . > /dev/null 2>&1
        rm -rf .git
    fi
fi

if [ $TYPE == "wordpress" ]; then
    if [ ! -d "$DIR/web/app/themes/$THEME" ]; then
        echo "Installing roots theme in $THEME dir"
        mkdir $DIR/web/app/themes/$THEME
        cd $DIR/web/app/themes/$THEME
        git clone --depth=1 git@github.com:tony-was/roots-was.git . > /dev/null 2>&1
        rm -rf .git
    else
        echo "Roots theme already exists for $NAME in $THEME dir"
    fi
fi
