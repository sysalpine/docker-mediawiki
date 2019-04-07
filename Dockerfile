FROM mediawiki:1.32.0

RUN echo "no\n" | pecl install redis-4.3.0 \
	  && docker-php-ext-enable redis

