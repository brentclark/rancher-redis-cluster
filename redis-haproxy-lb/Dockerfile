FROM haproxy:latest
MAINTAINER Brent Clark <brentgclark@gmail.com>

RUN apt-get update \
	&& apt-get dist-upgrade -y \
	&& apt-get install -y --no-install-recommends \
    bash \
    dnsutils \
#    iputils-ping \
#    iproute2 \
#    vim \
    curl \
    wget \
#    jq \
    net-tools \
  && rm -rf /var/lib/apt/lists/*

ADD dockerentrypoint.sh /usr/local/bin/
ADD start_haproxy.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/dockerentrypoint.sh 
RUN chmod +x /usr/local/bin/start_haproxy.sh

EXPOSE 6378
CMD ["/usr/local/bin/start_haproxy.sh"]
