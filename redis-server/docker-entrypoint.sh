#!/bin/bash

#stack_name=`echo -n $(curl -s http://rancher-metadata/latest/self/stack/name)`
#master_ip=$(leader_ip $stack_name redis-server)
#my_ip=`echo -n $(curl -s http://rancher-metadata/latest/self/container/primary_ip)`

giddyup service wait scale --timeout 60

my_ip=$(giddyup ip myip)
master_ip=$(giddyup leader get)

if redis-cli -h redis-sentinel -p 26379 ping; then
    master_ip=$(redis-cli -h redis-sentinel -p 26379 --raw sentinel get-master-addr-by-name mymaster | head -n 1)
fi

if [ "$my_ip" == "$master_ip" ]
then
  sed -i -E "s/^ *slaveof +([^ ]*)$/#slaveof \1/g" /usr/local/etc/redis/redis.conf
  echo "i am the leader"
else
  sed -i -E "s/^ *# +slaveof +.*$/slaveof $master_ip 6379/g" /usr/local/etc/redis/redis.conf
fi

#if [ -n "${REDIS_PASSWORD}" ]; then
  sed -i -E "s/^ *# +requirepass +.*$/requirepass ${REDIS_PASSWORD}/g" /usr/local/etc/redis/redis.conf
  sed -i -E "s/^ *# +masterauth +.*$/masterauth ${REDIS_PASSWORD}/g" /usr/local/etc/redis/redis.conf
#fi

sed -i -E "s/#.*$//" /usr/local/etc/redis/redis.conf
sed -i -E "/^\s*$/d" /usr/local/etc/redis/redis.conf

chown -R redis.redis /data

exec docker-entrypoint.sh "$@"
