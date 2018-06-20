#!/bin/bash

function leader_ip {
  echo -n $(curl -s http://rancher-metadata/latest/stacks/$1/services/$2/containers/0/primary_ip)
}

giddyup service wait scale --timeout 60
stack_name=`echo -n $(curl -s http://rancher-metadata/latest/self/stack/name)`
my_ip=$(giddyup ip myip)
redis_master_ip=$(leader_ip $stack_name redis-server)
sentinel_master_ip=$(giddyup leader get)

sed -i -E "s/^[ #]*sentinel announce-ip .*$/sentinel announce-ip ${my_ip}/" /usr/local/etc/redis/sentinel.conf
sed -i -E "s/^[ #]*sentinel announce-port .*$/sentinel announce-port 26379/" /usr/local/etc/redis/sentinel.conf
sed -i -E "s/^[ #]*sentinel monitor ([A-z0-9._-]+) 127.0.0.1 ([0-9]+) ([0-9]+).*$/sentinel monitor \1 ${redis_master_ip} \2 \3/g" /usr/local/etc/redis/sentinel.conf

if [ -n "${REDIS_PASSWORD}" ]; then
  sed -i -E "s/^[ #]*sentinel auth-pass mymaster .*$/sentinel auth-pass mymaster ${REDIS_PASSWORD}/" /usr/local/etc/redis/sentinel.conf
fi

# Here we do a clean up (I.e. Remove *all* lines that start with comments and / or are empty)
sed -i -E "s/#.*$//" /usr/local/etc/redis/sentinel.conf
sed -i -E "/^\s*$/d" /usr/local/etc/redis/sentinel.conf

chown -R redis.redis /data
exec docker-entrypoint.sh "$@"
