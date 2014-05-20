# Kalastack-Docker
# A magical Docker container for use with Kalabox

FROM ubuntu:12.04
MAINTAINER Mike Pirog <mike@kalamuna.com>
RUN echo "deb http://archive.ubuntu.com/ubuntu raring main restricted universe multiverse" > /etc/apt/sources.list
RUN apt-get update

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -s /bin/true /sbin/initctl

# Basic Requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python-setuptools curl openssh-server

# Weird fix for SSH to D
RUN mkdir -p /var/run/sshd
RUN echo 'root:kala' |chpasswd

# Prepare standard data directories for use by Kalabox
RUN mkdir -p /data/data
RUN mkdir -p /data/code
RUN mkdir -p /data/files

# Webserver
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install nginx

# Database
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server mysql-client

# PHP
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imap php5-fpm php5-mysql php-apc

# Drupal things
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install drush

# Is this a Twister Sister pin? On your uniform?
RUN apt-get clean

# mysql config
RUN sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf
RUN sed -i "s,datadir.*=.*,datadir         = /data/data,g" /etc/mysql/my.cnf
RUN rm -Rf /var/lib/mysql

# apparmor config
RUN echo "/data/data/ r," >> /etc/apparmor.d/local/usr.sbin.mysqld
RUN echo "/data/data/** rwk," >> /etc/apparmor.d/local/usr.sbin.mysqld

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# nginx site conf
ADD ./nginx-site.conf /etc/nginx/sites-available/default

# Supervisor Config
RUN /usr/bin/easy_install supervisor
ADD ./supervisord.conf /etc/supervisord.conf

# Drupal Initialization and Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# private expose
EXPOSE 22 80 3306

CMD ["/bin/bash", "/start.sh"]
