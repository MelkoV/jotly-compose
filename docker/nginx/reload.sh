#!/bin/sh
set -eu

watch_file="/var/www/certbot/.reload-nginx"
active_dir="/etc/nginx/certs/live"
fallback_dir="/etc/nginx/certs/fallback"

mkdir -p /var/www/certbot
touch "${watch_file}"

refresh_active_cert() {
    latest_fullchain="$(find /etc/letsencrypt/live -mindepth 2 -maxdepth 2 -name fullchain.pem 2>/dev/null | sort | tail -n 1 || true)"
    latest_privkey="$(find /etc/letsencrypt/live -mindepth 2 -maxdepth 2 -name privkey.pem 2>/dev/null | sort | tail -n 1 || true)"

    if [ -n "${latest_fullchain}" ] && [ -n "${latest_privkey}" ]; then
        ln -sf "${latest_fullchain}" "${active_dir}/fullchain.pem"
        ln -sf "${latest_privkey}" "${active_dir}/privkey.pem"
    else
        ln -sf "${fallback_dir}/fullchain.pem" "${active_dir}/fullchain.pem"
        ln -sf "${fallback_dir}/privkey.pem" "${active_dir}/privkey.pem"
    fi
}

refresh_active_cert

(
    while inotifywait -e close_write,create,attrib,move "${watch_file}" >/dev/null 2>&1; do
        refresh_active_cert
        nginx -s reload || true
    done
) &
