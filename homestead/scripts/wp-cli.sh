#!/usr/bin/env bash

echo "Checking if wp-cli is installed"

wp --info --allow-root > /dev/null 2>&1
if [ ! $? -eq 0 ]; then
    echo "Installing wp-cli"
    curl --silent -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /dev/null
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
else
    echo "wp-cli already installed"
fi