#!/usr/bin/env bash

# Laravel homestead original provisioning script
# https://github.com/laravel/settler

# Update Package List
apt-get update
apt-get upgrade -y

# Force Locale
echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
locale-gen en_US.UTF-8
# fixes php 5.6 install through ondrej ppa
export LANG=en_US.UTF-8

# Install ssh server
apt-get -y install openssh-server pwgen
mkdir -p /var/run/sshd
sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Install Some PPAs
apt-get install -y software-properties-common nano

apt-add-repository ppa:nginx/stable -y
apt-add-repository ppa:rwky/redis -y
apt-add-repository ppa:chris-lea/node.js -y
apt-add-repository ppa:ondrej/php5-5.6 -y

# Update Package Lists
apt-get update

# Create homestead user
adduser homestead
usermod -p $(echo secret | openssl passwd -1 -stdin) homestead

# Add homestead to the sudo group and www-data
usermod -aG sudo homestead
usermod -aG www-data homestead

# Install Some Basic Packages
apt-get install -y build-essential curl dos2unix gcc git git-flow libmcrypt4 libpcre3-dev \
make python2.7-dev python-pip re2c supervisor unattended-upgrades whois vim

# Install A Few Helpful Python Packages
pip install httpie
pip install fabric
pip install python-simple-hipchat

# Set My Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install PHP Stuffs
apt-get install -y php5-cli php5-dev php-pear \
php5-mysql php5-pgsql php5-sqlite \
php5-apcu php5-json php5-curl php5-dev php5-gd \
php5-gmp php5-imap php5-mcrypt php5-xdebug \
php5-memcached php5-redis

# Make MCrypt Available
ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
sudo php5enmod mcrypt

# Install Mailparse PECL Extension (version 2.1.6)
mkdir -p /tmp/mailparse/
cd /tmp/mailparse
wget http://pecl.php.net/get/mailparse-2.1.6.tgz
echo "0f84e1da1d074a4915a9bcfe2319ce84  mailparse-2.1.6.tgz" > md5sums
md5sum -c md5sums
tar xfz mailparse-2.1.6.tgz
cd mailparse-2.1.6 && phpize && ./configure && make && make install
cd / && rm -rf /tmp/mailparse
echo "extension=mailparse.so" > /etc/php5/mods-available/mailparse.ini
ln -s /etc/php5/mods-available/mailparse.ini /etc/php5/cli/conf.d/20-mailparse.ini

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Add Composer Global Bin To Path
printf "\nPATH=\"/home/homestead/.composer/vendor/bin:\$PATH\"\n" | tee -a /home/homestead/.profile

# Install Laravel Envoy
sudo su homestead <<'EOF'
/usr/local/bin/composer global require "laravel/envoy=~1.0"
EOF

# Set Some PHP CLI Settings
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php5/cli/php.ini

# Install Nginx & PHP-FPM
apt-get install -y nginx php5-fpm

rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default

# Setup Some PHP-FPM Options
ln -s /etc/php5/mods-available/mailparse.ini /etc/php5/fpm/conf.d/20-mailparse.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php5/fpm/php.ini

# Enable Remote xdebug
echo "xdebug.remote_enable = 1" >> /etc/php5/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_connect_back = 1" >> /etc/php5/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_port = 9000" >> /etc/php5/fpm/conf.d/20-xdebug.ini

echo "xdebug.var_display_max_depth = -1" >> /etc/php5/fpm/conf.d/20-xdebug.ini
echo "xdebug.var_display_max_children = -1" >> /etc/php5/fpm/conf.d/20-xdebug.ini
echo "xdebug.var_display_max_data = -1" >> /etc/php5/fpm/conf.d/20-xdebug.ini

echo "xdebug.max_nesting_level = 500" >> /etc/php5/fpm/conf.d/20-xdebug.ini

# Set The Nginx & PHP-FPM User
sed -i "s/user www-data;/user homestead;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

sed -i "s/user = www-data/user = homestead/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = homestead/" /etc/php5/fpm/pool.d/www.conf

sed -i "s/;listen\.owner.*/listen.owner = homestead/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/;listen\.group.*/listen.group = homestead/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php5/fpm/pool.d/www.conf

# Install Node
apt-get install -y nodejs
npm install -g grunt-cli
npm install -g gulp
npm install -g bower

# Install SQLite
apt-get install -y sqlite3 libsqlite3-dev

# Install A Few Other Things
apt-get install -y redis-server memcached beanstalkd

# Configure Beanstalkd
sudo sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd

# Configure default nginx site
block="server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root /var/www/html;
    server_name localhost;

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/app-error.log error;

    error_page 404 /index.php;

    sendfile off;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi.conf;
    }

    location ~ /\.ht {
        deny all;
    }
}
"

cat > /etc/nginx/sites-enabled/default
echo "$block" > "/etc/nginx/sites-enabled/default"
