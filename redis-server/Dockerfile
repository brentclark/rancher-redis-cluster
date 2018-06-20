FROM redis
MAINTAINER Brent Clark <brentgclark@gmail.com>

RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -qq -fy dist-upgrade
RUN DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -qq -fy --no-install-recommends --no-install-suggests install curl wget

ADD redis.conf /usr/local/etc/redis/redis.conf

RUN wget https://github.com/rancher/giddyup/releases/download/v0.19.0/giddyup -P /usr/local/bin
RUN chmod +x /usr/local/bin/giddyup

RUN echo "net.core.somaxconn=65535" >> /etc/sysctl.conf \
  && echo "vm.overcommit_memory=1" >> /etc/sysctl.conf \
  && echo "vm.swappiness=0" >> /etc/sysctl.conf 

RUN sed -i -E "s/^ *bind +.*$/bind 0.0.0.0/g" /usr/local/etc/redis/redis.conf \
#  && sed -i -E "s/^ *loglevel +.*$/loglevel debug/g" /usr/local/etc/redis/redis.conf \
  && sed -i -E "s/^ *dir +.*$/dir \/data/g" /usr/local/etc/redis/redis.conf \
#  && sed -i -E "s/^ *# +cluster-config-file +(.*)$/cluster-config-file \1/g" /etc/redis/redis.conf \
#  && sed -i -E "s/^ *# +cluster-node-timeout +(.*)$/cluster-node-timeout \1/g" /etc/redis/redis.conf \
  && sed -i -E "s/^ *appendonly +.*$/appendonly yes/g" /usr/local/etc/redis/redis.conf

ADD docker-entrypoint.sh /
WORKDIR /data
EXPOSE 6379
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
