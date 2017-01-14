#!/usr/bin/env bash

NAME=$1
TYPE=$2
THEME=$3
REPO=$4
DIR_SITES="/home/vagrant/sites"
NAME_EXT="$NAME.dev"
DIR="$DIR_SITES/$NAME_EXT"

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


#
#if [ ! -d "$DIR" ]; then
#    echo "Site folder for $NAME not found. Creating..."
#    mkdir $DIR
#fi

if [ -d $DIR ]; then
     echo "$NAME is already an established project"
else
    cd $DIR_SITES
    if [[ ! -z "$REPO" ]]; then
        echo "Cloning existing $NAME project from repo"
        pwd
        echo "git clone $REPO $NAME_EXT > /dev/null 2>&1"
        git clone $REPO $NAME_EXT #> /dev/null 2>&1
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
