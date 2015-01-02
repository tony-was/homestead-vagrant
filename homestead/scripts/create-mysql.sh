#!/usr/bin/env bash

DB=$1;
echo "Creating database for $DB"
mysql -uhomestead -psecret -e "DROP DATABASE IF EXISTS $DB";
mysql -uhomestead -psecret -e "CREATE DATABASE $DB";
