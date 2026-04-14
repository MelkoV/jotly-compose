#!/bin/sh
set -eu

watch_file="/var/www/certbot/.reload-nginx"

mkdir -p /var/www/certbot
touch "${watch_file}"

(
    while inotifywait -e close_write,create,attrib,move "${watch_file}" >/dev/null 2>&1; do
        nginx -s reload || true
    done
) &
