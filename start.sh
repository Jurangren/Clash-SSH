#!/bin/bash
mkdir /dev/net -pv > /dev/null
mknod /dev/net/tun c 10 200 > /dev/null
chmod 666 /dev/net/tun > /dev/null

service ssh start
useradd -r -s /bin/false sshd
/root/clash-linux-amd64 | tee -a /var/main/clash.log /var/main/main.log > /dev/null &
tail -f /var/main/main.log
