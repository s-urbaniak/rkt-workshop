### Prerequisites

- Vagrant

Installation:
```
$ vagrant up
```

To set up a route to your VM, execute ([iproute2](http://www.linuxfoundation.org/collaborate/workgroups/networking/iproute2) syntax):
```
# ip route add 172.16.28.0/24 dev vboxnet0 via 172.28.128.3
# ip route add 10.2.0.0/24 dev vboxnet0 via 172.28.128.3
```

### Single pod, multiple apps
```
# systemd-run \
    --unit=caddy \
    rkt run \
    --dns=8.8.8.8 \
    --volume=www,kind=host,source=/vagrant/src/www --mount=volume=www,target=/var/www/html \
    --insecure-options=image docker://joshix/caddy \
    s-urbaniak.github.io/images/inspector:0.0.2
```

### Poor man's service discovery

```
  redis     counter
10.2.0.10  10.2.0.11
    |          |
    +----+-----+
         |
      bridgenet
      10.2.0.1
```

```
# systemd-run \
    --unit=redis \
    rkt run \
    --dns=8.8.8.8 \
    --hostname=redis \
    --net=bridgenet:IP=10.2.0.10 \
    --hosts-entry 10.2.0.10=redis \
    --hosts-entry 10.2.0.11=counter \
    --insecure-options=image \
    docker://redis
```

```
# sudo systemd-run \
    --unit=counter \
    rkt run \
    --dns=8.8.8.8 \
    --hostname=counter \
    --net=bridgenet:IP=10.2.0.11 \
    --hosts-entry 10.2.0.10=redis \
    --hosts-entry 10.2.0.11=counter \
    s-urbaniak.github.io/images/redisservice:0.0.3 \
    -- \
    -redis-addr=redis:6379
```

To reset CNI and systemd state in case units fail or stop, execute:
```
# sh -c 'systemctl reset-failed && rkt gc --grace-period=0s'
```
