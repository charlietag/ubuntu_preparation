# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

#---------------
#Setup php-fpm pool "www"
#Value in pool "www" would override default valie in /etc/php/8.1/apache2/php.ini or /etc/php/8.1/cli/php.ini or /etc/php/8.1/fpm/php.ini
#---------------
# php-fpm config is under /etc/php/8.1 by default in Ubuntu 22
# task_copy_using_render
RENDER_CP_SED ${CONFIG_FOLDER}/etc/php/php_version/fpm/pool.d/www.conf /etc/php/${php_version}/fpm/pool.d/www.conf


#---------------
# make sure default session is writeable by php user
#---------------
chown -R ${current_user}.${current_user} /var/lib/php/*
