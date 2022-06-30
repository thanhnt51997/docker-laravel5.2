#!/bin/bash

# Update nginx to match worker_processes to no. of cpu's
procs=$(cat /proc/cpuinfo | grep processor | wc -l)
sed -i -e "s/worker_processes  1/worker_processes $procs/" /etc/nginx/nginx.conf

# Always chown webroot for better mounting
chown -Rf nginx:nginx /var/www/html

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf

#while [ true ]
#    do
#      php /var/www/html/artisan schedule:run --verbose --no-interaction &
#      sleep 10
#    done
