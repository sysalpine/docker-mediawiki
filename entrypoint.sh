#!/bin/sh

# Create Symlink for LocalSettings.php (Better Support for config volumes and k8s configmaps)
ln -sf /var/www/html/config/LocalSettings.php /var/www/html/LocalSettings.php

# Run DB Updates
if [ -f /var/www/html/config/LocalSettings.php ]; then
  php -f /var/www/html/maintenance/update.php
fi

# Fix file permissions for images/
chown -R www-data:www-data /var/www/html/images

apache2-foreground
