FROM php:8.1-apache as base

RUN apt-get update && apt-get install -y \
  libicu-dev git zip unzip \
  mariadb-client \
  libssl-dev pkg-config \
  vim

RUN docker-php-ext-install pdo_mysql intl
RUN pecl install mongodb redis

RUN cd /usr/local/bin \
  && curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer \
  && composer global require "laravel/lumen-installer:^1.0"

# For laravel to work we need to change APACHE_DOCUMENT_ROOT.
# see: https://hub.docker.com/_/php
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
ADD php.ini /usr/local/etc/php/

# enable mod_rewrite
RUN mv /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled
RUN /bin/sh -c a2enmod rewrite

# Remote build environment configs.
FROM base as remote

WORKDIR /var/www/html

COPY . /var/www/html

RUN composer install --no-dev --optimize-autoloader

EXPOSE 80

# Local docker-compose environment settings.
FROM base as local

WORKDIR /var/www/html

RUN echo 'memory_limit = -1' >> /usr/local/etc/php/conf.d/memory-limit.ini

EXPOSE 80

