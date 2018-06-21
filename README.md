# rancher-redis-cluster
rancher-redis-cluster

This is my version is running Redis and Sentinel, for High Availability, on Rancher.

Both redis-server and redis-sentinel image(s) will automatically find the Redis / Sentinel instances, will promote a master and monitor each other.

Most of my work was taken from [Shuliyey](https://github.com/Shuliyey) and [Ahfeel](https://github.com/ahfeel), but I added an extra layer, and that is the use of haproxy.
Haproxy is used for load balancing but more important, set up to be 'Sentinel aware', that way  you dont need to write 'Sentinel aware' code in your application.
Haproxy (via Sentinel) will figure out the redis master, with whom to route traffic too.

