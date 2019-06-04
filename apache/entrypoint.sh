#!/bin/sh

# Customize PHP Configuration
sed -i "s/memory_limit=.*/memory_limit=${PHP_MEMORY_LIMIT}/g" /usr/local/etc/php/conf.d/mediawiki.ini
sed -i "s/post_max_size=.*/post_max_size=${PHP_MAX_UPLOAD_SIZE}/g" /usr/local/etc/php/conf.d/mediawiki.ini
sed -i "s/upload_max_filesize=.*/upload_max_filesize=${PHP_MAX_UPLOAD_SIZE}/g" /usr/local/etc/php/conf.d/mediawiki.ini

# Create Symlink for LocalSettings.php (Better Support for config volumes and k8s configmaps)
ln -sf /var/www/html/config/LocalSettings.php /var/www/html/LocalSettings.php

# Run DB Updates
if [ -f /var/www/html/config/LocalSettings.php ]; then
  php -f /var/www/html/maintenance/update.php
fi

# Fix file permissions for images/
chown -R www-data:www-data /var/www/html/images

apache2-foreground
