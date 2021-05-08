FROM php:8.0.2-apache
ENV NODE_VERSION 15.10.0

COPY ./apache2.conf /etc/apache2/sites-enabled/000-default.conf

# Install OS utils
RUN apt-get update && apt-get install -yq --no-install-recommends \
  apt-utils ca-certificates wget curl zip git

# Install NODE
RUN curl -SLO https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz \
  && tar -xvzf node-v$NODE_VERSION-linux-x64.tar.gz -C / --strip-components=1 \
  && rm -rf "node-v$NODE_VERSION-linux-x64.tar.gz"

# Clear install files
RUN rm -rf /var/lib/apt/lists/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
  --install-dir=/usr/bin/ --filename=composer

# Install php extensions
RUN apt-get update && apt-get install -y && \
  docker-php-ext-install -j$(nproc) bcmath pdo_mysql && \
  rm -r /var/cache/*

# Install pecl extensions
RUN pecl install xdebug-3.0.3 && \
  docker-php-ext-enable xdebug

RUN a2enmod rewrite