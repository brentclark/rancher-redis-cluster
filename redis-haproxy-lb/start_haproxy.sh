#!/bin/bash
sleep 10s
echo "Running /usr/local/bin/dockerentrypoint.sh"
/usr/local/bin/dockerentrypoint.sh
echo "Running Haproxy"
/usr/local/sbin/haproxy -d -f /usr/local/etc/haproxy/haproxy.cfg
