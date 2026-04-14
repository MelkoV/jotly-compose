#!/bin/sh
set -eu

active_dir="/etc/nginx/certs/live"
fallback_dir="/etc/nginx/certs/fallback"
cert_file="${fallback_dir}/fullchain.pem"
key_file="${fallback_dir}/privkey.pem"

mkdir -p "${active_dir}" "${fallback_dir}"
mkdir -p /var/www/certbot

if [ ! -f "${cert_file}" ] || [ ! -f "${key_file}" ]; then
    cat > /tmp/jotly-cert.cnf <<'EOF'
[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = v3_req
distinguished_name = dn

[dn]
CN = jotly.ru

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = jotly.ru
DNS.2 = api.jotly.ru
EOF

    openssl req -x509 -nodes -days 3650 \
        -newkey rsa:2048 \
        -keyout "${key_file}" \
        -out "${cert_file}" \
        -config /tmp/jotly-cert.cnf
fi

rm -f "${active_dir}/fullchain.pem" "${active_dir}/privkey.pem"
ln -sf "${cert_file}" "${active_dir}/fullchain.pem"
ln -sf "${key_file}" "${active_dir}/privkey.pem"
