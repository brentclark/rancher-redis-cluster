FROM redis
MAINTAINER Brent Clark <brentgclark@gmail.com>

RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -qq -fy dist-upgrade
RUN DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -qq -fy --no-install-recommends --no-install-suggests install curl wget jq

RUN wget https://github.com/rancher/giddyup/releases/download/v0.19.0/giddyup -P /usr/local/bin
RUN chmod +x /usr/local/bin/giddyup

ADD sentinel.conf /usr/local/etc/redis/sentinel.conf

RUN echo "net.core.somaxconn=65535" >> /etc/sysctl.conf \
  && echo "vm.overcommit_memory=1" >> /etc/sysctl.conf \
  && echo "vm.swappiness=0" >> /etc/sysctl.conf

RUN sed -i -E "s/^ *bind +.*$/bind 0.0.0.0/g" /usr/local/etc/redis/sentinel.conf \
#  && sed -i -E "s/^ *loglevel +.*$/loglevel debug/g" /usr/local/etc/redis/sentinel.conf \
  && sed -i -E "s/^ *dir +.*$/dir \/data/g" /usr/local/etc/redis/sentinel.conf \
  && sed -i -E "s/^ *appendonly +.*$/appendonly yes/g" /usr/local/etc/redis/sentinel.conf 

ADD update-master-externalservice.sh /
ADD docker-entrypoint.sh /
WORKDIR /data
EXPOSE 26379
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["redis-sentinel", "/usr/local/etc/redis/sentinel.conf"]
