#!/bin/bash

echo "starting nginx"
service nginx start

echo "starting php5-fpm"
service php5-fpm start

echo "starting beanstalk"
/etc/init.d/beanstalkd start

echo "starting redis server"
redis-server /etc/redis/redis.conf

echo "starting ssh (ssh is the only service keeping this container alive)"
exec /usr/sbin/sshd -D