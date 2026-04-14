#!/bin/sh
set -eu

cert_dir="/etc/letsencrypt/live/jotly.ru"
cert_file="${cert_dir}/fullchain.pem"
key_file="${cert_dir}/privkey.pem"

mkdir -p "${cert_dir}"
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
