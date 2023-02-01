# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# ###########################################################
# php default version
# ###########################################################
# default php version for Ubuntu 22 is 8.1

# ###########################################################
# Install php
# ###########################################################
apt install -y \
  php \
  php-bcmath \
  php-cli \
  php-common \
  php-db \
  php-dev \
  php-enchant \
  php-fpm \
  php-gd \
  php-intl \
  php-ldap \
  php-mbstring \
  php-mysql \
  php-pear \
  php-odbc \
  php-apcu \
  php-soap \
  php-xml \
  libzip-dev \
  php-json \
  php-redis \
  php-tidy \
  php-curl \
  php${php_version}-opcache \
  php-zip

# php-curl is required by laravel (for curl dep packages)

# --- no need by default ---
  #
  # php-pear for pecl command
  # php-pear \
  # php-pgsql \
  # php-snmp \



# --------------------------------------------------------------------------------------
# Packages not included above, use pecl install
#   pecl - install *.so files which needs to be included by extension = xxxx.so
#   pear - should be replaced by composer.phar
# --------------------------------------------------------------------------------------

# Packages not included above, use pecl install
  # pecl channel-update pecl.php.net
  # php-imap \
  # php-pdo_dblib \
  # php-pecl-mongodb \
  # php-pecl-redis \
  # php-pspell \
  # php-sodium \
  # php-tidy \
  # php-xmlrpc \
  # php-opcache \

# --- For connecting to SQL server ---
# apt install -y unixODBC-devel
# pecl install pdo_sqlsrv sqlsrv

# --- successfully installed messages ---
# Build process completed successfully
# Installing '/usr/lib64/php/modules/sqlsrv.so'
# install ok: channel://pecl.php.net/sqlsrv-5.8.1

# configuration option "php_ini" is not set to php.ini location
# You should add "extension=sqlsrv.so" to php.ini
# You should add "extension=pdo_sqlsrv.so" to php.ini

# Default Ubuntu php config path: /etc/php/8.1/
# Higher PHP version: Ref. https://techvblogs.com/blog/install-php-8-2-ubuntu-22-04

# --------------------------------------------------------------------------------------

# Disable apache2.service
echo "systemctl disable apache2.service......"
systemctl stop apache2.service
systemctl disable apache2.service
systemctl mask apache2.service
echo ""

echo "systemctl disable php${php_version}-fpm.service......"
systemctl stop php${php_version}-fpm.service
systemctl disable php${php_version}-fpm.service
echo ""

# --------------------------------------------------------------------------
# Make sure php-fpm is not started by nginx (Ubuntu 22.04 default no configs for this)
# --------------------------------------------------------------------------
#sed -e 's/^#*/#/' -i /usr/lib/systemd/system/nginx.service.d/php-fpm.conf
# task_copy_using_cat
# chmod 755 /opt/php_fpm_scripts/*.sh
# *********************************
# Adding scripts into crontab
# *********************************
# local cron_php_fpm_script="/opt/php_fpm_scripts/php-fpm_decouple_nginx.sh"
# echo "Adding php-fpm check script into crontab..."
# sed -re "/${cron_php_fpm_script//\//\\/}/d" -i /etc/crontab
# echo "1 6 * * * root ${cron_php_fpm_script}" >> /etc/crontab
# $cron_php_fpm_script
