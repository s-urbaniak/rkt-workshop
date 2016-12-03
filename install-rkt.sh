#!/bin/bash
set -e
set -x

cd $(mktemp -d)

rkt_version="1.20.0"
acbuild_version="0.4.0"
cni_version="0.3.0"

dnf -y install \
    openssl \
    systemd-container \
    go \
    git \
    rng-tools \
    iptables

curl -O -L https://github.com/containernetworking/cni/releases/download/v"${cni_version}"/cni-v"${cni_version}".txz
tar -xJf cni-v"${cni_version}".txz
install -Dm755 bridge /usr/bin/bridge
install -Dm755 cnitool /usr/bin/cnitool
install -Dm755 dhcp /usr/bin/dhcp
install -Dm755 flannel /usr/bin/flannel
install -Dm755 host-local /usr/bin/host-local
install -Dm755 ipvlan /usr/bin/ipvlan
install -Dm755 loopback /usr/bin/loopback
install -Dm755 macvlan /usr/bin/macvlan
install -Dm755 ptp /usr/bin/ptp
install -Dm755 tuning /usr/bin/tuning

curl -O -L https://github.com/containers/build/releases/download/v"${acbuild_version}"/acbuild-v"${acbuild_version}".tar.gz
tar -xzf acbuild-v"${acbuild_version}".tar.gz
install -Dm755 acbuild-v"${acbuild_version}"/acbuild /usr/bin/acbuild
install -Dm755 acbuild-v"${acbuild_version}"/acbuild-chroot /usr/bin/acbuild-chroot
install -Dm755 acbuild-v"${acbuild_version}"/acbuild-script /usr/bin/acbuild-script

curl -O -L https://github.com/coreos/rkt/releases/download/v"${rkt_version}"/rkt-"${rkt_version}"-1.x86_64.rpm
rpm -Uvh rkt-"${rkt_version}"-1.x86_64.rpm

gpasswd -a vagrant rkt
gpasswd -a vagrant rkt-admin

cp /vagrant/selinux.config /etc/selinux/config
setenforce 0

mkdir --parents /etc/rkt/net.d
install -Dm644 /vagrant/bridgenet.conf /etc/rkt/net.d/bridgenet.conf

cp /vagrant/bashrc /home/vagrant/.bashrc
chown vagrant:vagrant ~/.bashrc

systemctl daemon-reload

systemctl enable rngd
systemctl start rngd

install -d --group=vagrant --owner=vagrant /home/vagrant/gopath /home/vagrant/gopath/src /home/vagrant/gopath/bin /home/vagrant/gopath/pkg
