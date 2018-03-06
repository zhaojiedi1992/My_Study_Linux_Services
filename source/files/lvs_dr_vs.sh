#!/bin/bash
#Author:wangxiaochun
#Date:2017-08-13
vip='10.0.46.151'
iface='ens33:1'
mask='255.255.255.255'
port='80'
rs1='192.168.46.158'
rs2='192.168.46.159'
rs3='192.168.46.160'
scheduler='wrr'
type='-g'
rpm -q ipvsadm &> /dev/null || yum -y install ipvsadm &> /dev/null

case $1 in
start)
    ifconfig $iface $vip netmask $mask  up
    iptables -F
 
    ipvsadm -A -t ${vip}:${port} -s $scheduler
    ipvsadm -a -t ${vip}:${port} -r ${rs1} $type -w 1
    ipvsadm -a -t ${vip}:${port} -r ${rs2} $type -w 1
    ipvsadm -a -t ${vip}:${port} -r ${rs3} $type -w 1
    echo "The VS Server is Ready!"
    ;;
stop)
    ipvsadm -C
    ifconfig $iface down
    echo "The VS Server is Canceled!"
    ;;
*)
    echo "Usage: $(basename $0) start|stop"
    exit 1
    ;;
esac
