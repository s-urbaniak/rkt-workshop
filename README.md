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
