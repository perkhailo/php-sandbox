FROM php:8-fpm

ENV NODE_VERSION 14.17.0

# Install system dependencies
RUN apt-get update && apt-get install -yq --no-install-recommends \
  git \
  curl \
  libpng-dev \
  libonig-dev \
  libxml2-dev \
  zip \
  unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN apt-get update && apt-get install -y && \
  docker-php-ext-install -j$(nproc) pdo_mysql mbstring exif pcntl bcmath gd && \
  rm -r /var/cache/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
  --install-dir=/usr/bin/ --filename=composer \
  && rm -f /usr/bin/composer

# Install NODE
RUN curl -SLO https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz \
  && tar -xvzf node-v$NODE_VERSION-linux-x64.tar.gz -C / --strip-components=1 \
  && rm -rf "node-v$NODE_VERSION-linux-x64.tar.gz"

# Install pecl extensions
RUN pecl install xdebug \
  && docker-php-ext-enable xdebug \
  && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.client_host = host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install opcache extension for PHP accelerator
RUN docker-php-ext-install opcache \
  && docker-php-ext-enable opcache \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get autoremove -y

# Clear install files
RUN rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www
