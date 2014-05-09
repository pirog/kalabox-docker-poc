#!/bin/bash

# Replace the nginx server name for this container with an ENV variable
if [ -n "${KALABOX_SERVER_NAME+1}" ]; then
  /usr/bin/sed -i "s/SERVER_NAME/${KALABOX_SERVER_NAME}/" /etc/nginx/sites-available/default
fi
unset KALABOX_SERVER_NAME

# start all the services
/usr/local/bin/supervisord -n
