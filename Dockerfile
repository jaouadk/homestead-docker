FROM ubuntu:18.04

# Maintainer
LABEL maintainer="Jaouad E. <jaouad.elmoussaoui@gmail.com>"

# Environment
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_VERSION 7.3

# Update package list and upgrade available packages
RUN apt update && apt upgrade -y

# Ensure common dependencies are installed
RUN apt install -y \
  software-properties-common \
  ca-certificates \
  curl

# Add PPAs and repositories
RUN apt-add-repository ppa:nginx/stable -y
RUN apt-add-repository ppa:ondrej/php -y
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

# Update package lists & install some basic packages
RUN apt update && apt install --fix-missing -y \
  apt-utils \
  bash-completion \
  beanstalkd \
  build-essential \
  cifs-utils \
  curl \
  git \
  libmcrypt4 \
  libpcre3-dev \
  libpng-dev \
  libsqlite3-dev \
  mcrypt \
  memcached \
  nginx \
  nodejs \
  openssh-server \
  pwgen \
  redis-server \
  software-properties-common \
  sqlite3 \
  supervisor \
  vim \
  yarn

# Configure locale and timezone
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# PHP and PHP dependencies installation
RUN apt install \
  --allow-downgrades \
  --allow-remove-essential \
  --allow-change-held-packages -y \
  php-pear \
  php${PHP_VERSION}-apcu \
  php${PHP_VERSION}-bcmath \
  php${PHP_VERSION}-cli \
  php${PHP_VERSION}-curl \
  php${PHP_VERSION}-dev \
  php${PHP_VERSION}-fpm \
  php${PHP_VERSION}-gd \
  php${PHP_VERSION}-gmp \
  php${PHP_VERSION}-imap \
  php${PHP_VERSION}-intl \
  php${PHP_VERSION}-json \
  php${PHP_VERSION}-ldap \
  php${PHP_VERSION}-mailparse \
  php${PHP_VERSION}-mbstring \
  php${PHP_VERSION}-mcrypt \
  php${PHP_VERSION}-memcached \
  php${PHP_VERSION}-mysql \
  php${PHP_VERSION}-pgsql \
  php${PHP_VERSION}-readline \
  php${PHP_VERSION}-redis \
  php${PHP_VERSION}-soap \
  php${PHP_VERSION}-sqlite3 \
  php${PHP_VERSION}-xdebug \
  php${PHP_VERSION}-xml \
  php${PHP_VERSION}-zip

# Update package alternatives
RUN update-alternatives --set php /usr/bin/php${PHP_VERSION} && \
  update-alternatives --set php-config /usr/bin/php-config${PHP_VERSION} && \
  update-alternatives --set phpize /usr/bin/phpize${PHP_VERSION}

# Install Composer package manager
RUN curl -sS https://getcomposer.org/installer | php && \
  mv composer.phar /usr/local/bin/composer

# PHP CLI configuration
RUN sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/cli/php.ini && \
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/cli/php.ini && \
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/cli/php.ini && \
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/cli/php.ini

# PHP FPM configuration
RUN sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/fpm/php.ini

RUN echo "xdebug.remote_enable = 1" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini && \
  echo "xdebug.remote_connect_back = 1" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini && \
  echo "xdebug.remote_port = 9000" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini && \
  echo "xdebug.max_nesting_level = 512" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini && \
  echo "opcache.revalidate_freq = 0" >> /etc/php/${PHP_VERSION}/mods-available/opcache.ini

# Remove Nginx default configuration file
RUN rm /etc/nginx/sites-enabled/default && \
  rm /etc/nginx/sites-available/default

# Set the Nginx and PHP-FPM user
RUN sed -i "s/user www-data;/user homestead;/" /etc/nginx/nginx.conf && \
  sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf && \
  sed -i "s/user = www-data/user = homestead/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
  sed -i "s/group = www-data/group = homestead/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
  sed -i "s/;listen\.owner.*/listen.owner = homestead/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
  sed -i "s/;listen\.group.*/listen.group = homestead/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

# Add OpenSSL certificate authority configuration to PHP FPM
RUN printf "[openssl]\n" | tee -a /etc/php/${PHP_VERSION}/fpm/php.ini && \
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/${PHP_VERSION}/fpm/php.ini

# Add cURL certificate authority configuration to PHP FPM
RUN printf "[curl]\n" | tee -a /etc/php/${PHP_VERSION}/fpm/php.ini && \
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/${PHP_VERSION}/fpm/php.ini

# Disable x-debug on the CLI
RUN phpdismod -s cli xdebug

# Install WordPress CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
  chmod +x wp-cli.phar && \
  mv wp-cli.phar /usr/local/bin/wp

# Configure SSH service
RUN  mkdir -p /var/run/sshd && \
  sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
  sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
  sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Create homestead user
RUN adduser homestead && \
  usermod -p $(echo secret | openssl passwd -1 -stdin) homestead

# Add homestead to the sudo and www-data groups
RUN usermod -aG sudo homestead && \
  usermod -aG www-data homestead

# Instal some commonly used Node packages
RUN npm install -g grunt-cli && \
  npm install -g gulp && \
  npm install -g bower

# Configure beanstalkd and redis
RUN sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd && \ 
  sed -i "s/daemonize yes/daemonize no/" /etc/redis/redis.conf

# Copy nginx virtualhost configuration
COPY example.nginx.conf /etc/nginx/sites-available/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Add serve.sh script
ADD serve.sh /serve.sh
RUN chmod +x /*.sh

# Add supervisor configuration
ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Expose HTTP, SSH adn debugging ports
EXPOSE 80 22 35729 9876

CMD ["/usr/bin/supervisord"]
