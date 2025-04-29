FROM alpine:3.21

LABEL Maintainer="Romeo"
LABEL Description="A lightweight container with Nginx 1.26+ & Multiple php version (8.2 ~ 8.4, default PHP 8.3) based on Alpine Linux."

# Can only support php 8.2 ~ 8.4. (PHP 8.1 can be easily supported if using Alpine 3.19)
ARG PHP_VERSION=83
# Can be only prod or dev
ARG ENV=prod
ARG TIMEZONE=America/New_York

# Setup document root
WORKDIR /var/www/project

# Install packages and remove default server definition
RUN apk update && \
  apk upgrade --available && \
  apk add --no-cache \
    php${PHP_VERSION} \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-ctype \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-fileinfo \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-iconv \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-openssl \
    php${PHP_VERSION}-pcntl \
    php${PHP_VERSION}-pdo_mysql \
    php${PHP_VERSION}-phar \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-session \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-sockets \
    php${PHP_VERSION}-tokenizer \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-xmlreader \
    php${PHP_VERSION}-xmlwriter \
    php${PHP_VERSION}-zip \
    nginx \
    composer \
    supervisor  \
    tzdata && \
  rm -rf /var/cache/apk/* && \
  ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
  echo "${TIMEZONE}" > /etc/timezone && \
  ln -sf /usr/bin/php${PHP_VERSION} /usr/bin/php && \
  ln -sf /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm

# for development environment
RUN if [ $ENV = dev ]; then \
    apk add git \
      vim \
      curl && \
    rm -rf /var/cache/apk/* && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone \
  ;fi

# Configure nginx - http
COPY config/nginx.conf /etc/nginx/nginx.conf
# Configure nginx - default server
COPY config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
ENV PHP_INI_DIR /etc/php${PHP_VERSION}
COPY config/fpm-pool.conf ${PHP_INI_DIR}/php-fpm.d/www.conf
COPY config/php-${ENV}.ini ${PHP_INI_DIR}/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN mkdir -p /var/www/project/public && \
    chown -R nobody:nobody /var/www/project /run /var/lib/nginx /var/log/nginx && \
    echo '<?php phpinfo(); ?>' > /var/www/project/public/index.php && \
    php -v && \
    php -m \

# Switch to use a non-root user from here on
USER nobody

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
