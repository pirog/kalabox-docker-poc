# Kalastack-Docker
# A magical Docker container for use with Kalabox

FROM ubuntu:12.04
MAINTAINER Mike Pirog <mike@kalamuna.com>

# Get the most recent things
RUN apt-get update
# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl

# Basic requirements for Kalabox/Switchboard-based containers
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure apt-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git rsync curl openssh-server php5 php5-curl php5-sqlite php5-mcrypt mysql-client python-setuptools
# Install composer and set it vendor dir to $PATH
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
# Prepare directories for composer
RUN mkdir -p /usr/share/composer
ENV COMPOSER_HOME /usr/share/composer
ENV COMPOSER_BIN_DIR /usr/local/bin
# Install DRUSH and Switchboard
RUN composer global require drush/drush:6.*
RUN git clone https://github.com/fluxsauce/switchboard.git /usr/share/composer/vendor/drush/drush/commands/switchboard
RUN cd /usr/share/composer/vendor/drush/drush/commands/switchboard && composer update --no-dev
RUN drush cc drush
# Weird fix for SSH to D
RUN mkdir -p /var/run/sshd
RUN echo 'root:kala' | chpasswd

# Webserver
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install nginx

# Database
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server

# PHP
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-gd php5-intl php-pear php5-imap php5-fpm php5-mysql php-apc php5-xdebug

# Is this a Twisted Sister pin? On your uniform?
RUN apt-get clean

# mysql config
ADD ./my.cnf /etc/mysql/conf.d/kalabox.cnf
RUN rm -Rf /var/lib/mysql

# apparmor config
RUN echo "/data/data/ r," >> /etc/apparmor.d/local/usr.sbin.mysqld
RUN echo "/data/data/** rwk," >> /etc/apparmor.d/local/usr.sbin.mysqld

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD ./nginx-site.conf /etc/nginx/sites-available/default

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i -e "s/memory_limit = 128M/memory_limit = 512M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/post_max_size = 8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize = 2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;
RUN sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php5-fpm.sock/g" /etc/php5/fpm/pool.d/www.conf
RUN sed -i -e "s/;listen.owner = www-data/listen.owner = www-data/g" /etc/php5/fpm/pool.d/www.conf
RUN sed -i -e "s/;listen.group = www-data/listen.group = www-data/g" /etc/php5/fpm/pool.d/www.conf
RUN sed -i -e "s/;listen.mode = www-data/listen.mode = 0660/g" /etc/php5/fpm/pool.d/www.conf

# php5-apc
RUN sed -i '$a apc.shm_size=128M' /etc/php5/conf.d/apc.ini
RUN sed -i '$a apc.include_once_override=0' /etc/php5/conf.d/apc.ini
# php5-xdebug
# @todo this assumes 1.3.3.1 is your host machine, need to abstract out
# in the future
RUN sed -i '$a xdebug.remote_host="1.3.3.1"' /etc/php5/conf.d/xdebug.ini
RUN sed -i '$a xdebug.remote_enable=1' /etc/php5/conf.d/xdebug.ini
RUN sed -i '$a xdebug.remote_port=9000' /etc/php5/conf.d/xdebug.ini
RUN sed -i '$a xdebug.remote_handler="dbgp"' /etc/php5/conf.d/xdebug.ini
RUN sed -i '$a xdebug.remote_autostart=1' /etc/php5/conf.d/xdebug.ini

# Supervisor Config
RUN /usr/bin/easy_install supervisor
ADD ./supervisord.conf /etc/supervisord.conf

# Drupal Initialization and Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# private expose
EXPOSE 22 80 3306

# NOW IS THE TIME ON SPROCKETS WHERE WE DANCE
CMD ["/bin/bash", "/start.sh"]
