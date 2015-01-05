#!/usr/bin/env bash

validlocale en_AU.UTF-8 > /dev/null 2>&1
if [ ! $? -eq 0 ]; then
    echo "Installing en_AU.UTF-8"
    locale-gen en_AU.UTF-8
else
    echo "en_AU.UTF-8 already installed"
fi