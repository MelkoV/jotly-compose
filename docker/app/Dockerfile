FROM php:8.5-fpm

LABEL maintainer="ant-smorodin@ya.ru"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    $PHPIZE_DEPS \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    libxml2-dev \
    libicu-dev \
    zlib1g-dev \
    libpq-dev \
    supervisor \
    ; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j"$(nproc)" \
        pdo_mysql \
        pdo_pgsql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
    ; \
    pecl install apcu; \
    docker-php-ext-enable apcu; \
    echo "apc.enable_cli=1" > /usr/local/etc/php/conf.d/apcu-cli.ini; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/pear ~/.pearrc

COPY --from=composer:2.9.5 /usr/bin/composer /usr/bin/composer

ADD docker/php/php.ini /usr/local/etc/php/conf.d/40-custom.ini
ADD docker/php/output.conf /usr/local/etc/php/conf.d/output.conf
COPY --from=compose_src docker/app/zz-tcp-fpm.conf /usr/local/etc/php-fpm.d/zz-docker.conf

COPY . /var/www/html
WORKDIR /var/www/html

RUN composer install --no-dev

COPY --from=compose_src docker/app/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 9000

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
