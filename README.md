### Prerequisites

- Vagrant

Installation:
```
$ vagrant up
```

To set up a route to your VM, execute ([iproute2](http://www.linuxfoundation.org/collaborate/workgroups/networking/iproute2) syntax):
```
# ip route add 172.16.28.0/24 via <vm-ip>
# ip route add 10.2.0.0/24 via <vm-ip>
```

Replace `<vm-ip>` with the corresponding Vagrant VM interface and IP address. Example:
```
$ vagrant ssh -c 'ip address show dev eth1 | grep inet'
    inet 172.28.128.3/24 brd 172.28.128.255 scope global dynamic eth1
    inet6 fe80::a00:27ff:fe94:5bea/64 scope link 
Connection to 127.0.0.1 closed.
0 14:02 x220 ~/src/rkt-workshop (master)
$ sudo ip route add 172.16.28.0/24 via 172.28.128.3
$ sudo ip route add 10.2.0.0/24 via 172.28.128.3
```

### Single pod, multiple apps
```
# sudo rkt run \
    --volume=www,kind=host,source=/vagrant/src/www \
    --mount=volume=www,target=/var/www/html \
    --insecure-options=image docker://joshix/caddy
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
