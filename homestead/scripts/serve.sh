#!/usr/bin/env bash

NAME=$1
TYPE=$2
NAME_EXT="$NAME.dev"

echo "Setting up virual server for $NAME"
case $TYPE in
  'laravel')
  ROOT="/home/vagrant/sites/$NAME_EXT/public"
  echo "$NAME is a Laravel project."
  ;;
  'wordpress')
  ROOT="/home/vagrant/sites/$NAME_EXT/web"
  echo "$NAME is a WordPress project."
  ;;
  'drupal')
  ROOT="/home/vagrant/sites/$NAME_EXT/web"
  echo "$NAME is a Drupal project."
  ;;
esac

block="server {
    listen 80;
    server_name $NAME_EXT;
    root "$ROOT";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$NAME_EXT-error.log error;

    error_page 404 /index.php;

    sendfile off;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_intercept_errors on;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
    }

    location ~ /\.ht {
        deny all;
    }
}
"

echo "$block" > "/etc/nginx/sites-available/$NAME_EXT"
ln -fs "/etc/nginx/sites-available/$NAME_EXT" "/etc/nginx/sites-enabled/$NAME_EXT"
service nginx restart
service php5-fpm restart
