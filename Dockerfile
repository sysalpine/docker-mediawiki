FROM mediawiki:1.32.0

ENV REDIS_VERSION=4.3.0 \
    MATH_EXTENSION_URL=https://extdist.wmflabs.org/dist/extensions/Math-REL1_32-b976708.tar.gz

## Redis Support
RUN echo "no\n" | pecl install redis-${REDIS_VERSION} \
	  && docker-php-ext-enable redis \
    && rm -rf /tmp/pear

## Install Math Extension
RUN curl --output /tmp/math.tar ${MATH_EXTENSION_URL} \
    && tar xf /tmp/math.tar -C /var/www/html/extensions \
    && chown www-data:www-data -R /var/www/html/extensions/Math \
    && rm -rf /tmp/math.tar
