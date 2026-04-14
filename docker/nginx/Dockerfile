# syntax=docker/dockerfile:1.7

FROM node:20-alpine AS frontend-builder

WORKDIR /app

COPY --from=frontend_src package.json package-lock.json ./
RUN npm ci

COPY --from=frontend_src . .

ARG VITE_API_URL=https://api.jotly.ru
ENV VITE_API_URL=${VITE_API_URL}

RUN npm run build

FROM nginx:1.27-alpine

RUN apk add --no-cache inotify-tools openssl

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY docker/nginx/entrypoint.sh /docker-entrypoint.d/10-bootstrap-certs.sh
COPY docker/nginx/reload.sh /docker-entrypoint.d/20-watch-cert-reloads.sh
COPY --from=frontend-builder /app/dist /usr/share/nginx/html

RUN chmod +x /docker-entrypoint.d/10-bootstrap-certs.sh /docker-entrypoint.d/20-watch-cert-reloads.sh
