#!/usr/bin/env bash

DB=$1;
mysqlshow -uhomestead -psecret $DB > /dev/null 2>&1
if [ ! $? -eq 0 ]; then
    echo "Creating database for $DB"
    mysql -uhomestead -psecret -e "CREATE DATABASE IF NOT EXISTS \`$DB\`" > /dev/null 2>&1
else
    echo "Database for $DB already exists"
fi