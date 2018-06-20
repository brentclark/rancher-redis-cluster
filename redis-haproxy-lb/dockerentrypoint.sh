#!/bin/bash

REDIS_SERVERS=($(dig +short redis-server | sed 's/\n//'))
SENTINEL_SERVERS=($(dig +short redis-sentinel | sed 's/\n//'))
CONFIGFILE='/usr/local/etc/haproxy/haproxy.cfg'

echo "
frontend redis-cluster
  mode tcp
  option tcplog
  bind *:6378 
  #acl network_allowed src ${REDIS_ACL}
  #tcp-request connection reject if !network_allowed" > "${CONFIGFILE}"

for (( a=0; a<${#REDIS_SERVERS[@]}; a++ )); do
  echo "  use_backend redis-node${a} if { srv_is_up(redis-node${a}/redis-${a}:${REDIS_SERVERS[a]}:6379) } { nbsrv(check_master_redis-${a}) ge 3 }" >> "${CONFIGFILE}"
done

echo "
  # If sentinel cant tell us, well, fall back to master detection
  default_backend redis-cluster" >> "${CONFIGFILE}"

for (( a=0; a<${#REDIS_SERVERS[@]}; a++ )); do
echo "
backend redis-node${a}
  mode tcp
  balance first
  option tcp-check
  tcp-check send AUTH\ ${REDIS_PASSWORD}\r\n
  #tcp-check expect string +OK
  #tcp-check send info\ replication\r\n
  #tcp-check expect string role:master
  tcp-check send PING\r\n
  tcp-check expect string +PONG
  tcp-check send info\ replication\r\n
  tcp-check expect string role:master
  tcp-check send QUIT\r\n
  tcp-check expect string +OK
  server redis-${a}:"${REDIS_SERVERS[a]}":6379 "${REDIS_SERVERS[a]}":6379 maxconn 5000 check inter 1s" >> "${CONFIGFILE}"
done

echo "
backend redis-cluster
  mode tcp
  balance first
  option tcp-check
  tcp-check send AUTH\ ${REDIS_PASSWORD}\r\n
  tcp-check expect string +OK
  tcp-check send info\ replication\r\n
  tcp-check expect string role:master
  tcp-check send info\ persistence\r\n
  tcp-check expect string loading:0" >> "${CONFIGFILE}"

for (( a=0; a<${#REDIS_SERVERS[@]}; a++ )); do
  echo "  server redis-${a}:${REDIS_SERVERS[a]}:6379 ${REDIS_SERVERS[a]}:6379 maxconn 5000 check inter 1s" >> "${CONFIGFILE}"
done

for (( a=0; a<${#REDIS_SERVERS[@]}; a++ )); do
echo "
backend check_master_redis-${a}
  mode tcp
  option tcp-check
  tcp-check send PING\r\n
  tcp-check expect string +PONG
  tcp-check send SENTINEL\ master\ mymaster\r\n
  tcp-check expect string ${REDIS_SERVERS[a]}
  tcp-check send QUIT\r\n
  tcp-check expect string +OK" >> "${CONFIGFILE}"

  for (( b=0; b<${#REDIS_SERVERS[@]}; b++ )); do
    echo "  server redis-${a}:${SENTINEL_SERVERS[b]}:26379 ${SENTINEL_SERVERS[b]}:26379 check inter 2s" >> "${CONFIGFILE}"
  done
  for (( c=0; c<${#SENTINEL_SERVERS[@]}; c++ )); do
    echo "  server redis-sentinel${c}:${SENTINEL_SERVERS[c]}:26379 ${SENTINEL_SERVERS[c]}:26379 check inter 2s" >> "${CONFIGFILE}"
  done
done
