FROM php:7.3.9-fpm-buster

ENV MEDIAWIKI_MAJOR_VERSION=1.33 \
    MEDIAWIKI_BRANCH=REL1_33 \
    MEDIAWIKI_VERSION=1.33.0 \
    PHP_MEMORY_LIMIT=128M \
    PHP_MAX_UPLOAD_SIZE=16M \
    MATH_EXTENSION_URL=https://extdist.wmflabs.org/dist/extensions/Math-REL1_33-183fd5c.tar.gz \
    SIMPLEMATHJAX_EXTENSION_GIT_URL=https://github.com/jmnote/SimpleMathJax.git \
    SPOILERS_EXTENSION_VERSION=2.2.0 \
    SPOILERS_EXTENSION_URL=https://github.com/Telshin/Spoilers/archive/2.2.0.tar.gz

# System dependencies
RUN set -ex; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    git \
    imagemagick \
    # Required for SyntaxHighlighting
    python3 \
  ; \
  rm -rf /var/lib/apt/lists/*

# Install the PHP extensions we need
RUN set -ex; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    libicu-dev \
  ; \
  \
  docker-php-ext-install \
    intl \
    mbstring \
    mysqli \
    opcache \
  ; \
  \
    echo "no\n" | pecl install apcu-5.1.17; \
    echo "no\n" | pecl install redis-4.3.0; \
    docker-php-ext-enable \
      apcu \
      redis \
  ; \
  \
  # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
  apt-mark auto '.*' > /dev/null; \
  apt-mark manual $savedAptMark; \
  ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
    | awk '/=>/ { print $3 }' \
    | sort -u \
    | xargs -r dpkg-query -S \
    | cut -d: -f1 \
    | sort -u \
    | xargs -rt apt-mark manual; \
  \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -rf /var/lib/apt/lists/*; \
  rm -rf /tmp/pear

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini

COPY mediawiki.ini /usr/local/etc/php/conf.d/mediawiki.ini

# SQLite Directory Setup
RUN mkdir -p /var/www/data \
    && chown -R www-data:www-data /var/www/data

# MediaWiki setup
RUN curl -fSL "https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz" -o mediawiki.tar.gz \
    && tar -xz --strip-components=1 -f mediawiki.tar.gz \
    && rm mediawiki.tar.gz \
    && chown -R www-data:www-data extensions skins cache images

# Install Math Extension
RUN curl -fSL -o /tmp/math.tar ${MATH_EXTENSION_URL} \
    && tar xf /tmp/math.tar -C /var/www/html/extensions \
    && chown www-data:www-data -R /var/www/html/extensions/Math \
    && rm -rf /tmp/math.tar

# Install SimpleMathJax Extension
RUN git clone --recursive ${SIMPLEMATHJAX_EXTENSION_GIT_URL} /var/www/html/extensions/SimpleMathJax \
    && rm -rf /var/www/html/extensions/SimpleMathJax/.git* \
    && chown www-data:www-data -R /var/www/html/extensions/SimpleMathJax

# Install Spoilers Extension
RUN curl -fSL -o /tmp/spoilers.tar ${SPOILERS_EXTENSION_URL} \
    && tar xf /tmp/spoilers.tar -C /tmp \
    && mv /tmp/Spoilers-${SPOILERS_EXTENSION_VERSION} /var/www/html/extensions/Spoilers \
    && chown www-data:www-data -R /var/www/html/extensions/Spoilers \
    && rm -rf /tmp/spoilers.tar

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
