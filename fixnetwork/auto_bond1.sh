#!/bin/bash

# Program:

# This program is create bond interface.

# History:

# 2014/03/05 wangwentao First release

export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"

confDir="/etc/sysconfig/network-scripts"

backConfDir="/etc/sysconfig/ifcfg.bak.$(date +%Y%m%d_%H:%M:%S)"



# 打印帮助信息

# -b 参数创建bond+bridge接口 并创建私网IP子接口

# -t 参数只创建bond接口 并创建私网IP子接口

# ip mask参数为空时从网卡配置中读取信息

help() {

cat >> /dev/stdout <<EOF

Usage: $(basename $0) { -b | -t } eth[m] eth[n] [ public ip address ] [ network mask ] [gateway]

Example: ./$(basename $0) -b 1 3 192.168.1.23 255.255.255.248  192.168.1.254

Example: ./$(basename $0) -t 0 2 192.168.1.24 255.255.255.0  192.168.1.254

Example: ./$(basename $0) -b 1 2

EOF

exit 1

}

# 检查网卡号、IP地址和子网掩码是否符合规范

checkEthnNum() {

if ! echo $ethn | grep "[0-9]" > /dev/null; then

echo -e "\n eth[n] number input error! \n"

exit 1

fi
}

checkEthmNum() {

if ! echo $ethm | grep "[0-9]" > /dev/null; then

echo -e "\n eth[m] number input error! \n"

exit 1

fi
}

checkIp() {

if ! echo $pubIp | grep "[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}" > /dev/null; then

echo -e "\n public ip address input error! \n"

exit 1

fi

if ! echo $pubMask | grep "[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}" > /dev/null; then

echo -e "\n public netmask input error! \n"

exit 1

fi

if ! echo $pubGW | grep "[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}" > /dev/null; then

echo -e "\n public gateway input error! \n"

exit 1

fi


}

# 修改eth*网卡配置文件

create_eth() {

ethmhwaddr=`more $confDir/ifcfg-eth$ethm |grep HWADDR|awk -F"=" '{print $2}'`
ethnhwaddr=`more $confDir/ifcfg-eth$ethn |grep HWADDR|awk -F"=" '{print $2}'`

mv -f $confDir/ifcfg-eth$ethm $backConfDir
mv -f $confDir/ifcfg-eth$ethn $backConfDir

cat >> $confDir/ifcfg-eth$ethm <<EOF

DEVICE=eth$ethm

HWADDR=$ethmhwaddr

ONBOOT=yes

BOOTPROTO=static

USERCTL=no

MASTER=bond1

SLAVE=yes

EOF

cat >> $confDir/ifcfg-eth$ethn <<EOF

DEVICE=eth$ethn

HWADDR=$ethnhwaddr

ONBOOT=yes

BOOTPROTO=static

USERCTL=no

MASTER=bond1

SLAVE=yes

EOF

}

# 创建bond配置文件 包括公网IP和私网IP子接口

create_bond() {

create_eth

#mv -f $confDir/ifcfg-br* $backConfDir
mv -f $confDir/ifcfg-bond1 $backConfDir

cat >> $confDir/ifcfg-bond1 <<EOF

DEVICE=bond1

ONBOOT=yes

BOOTPROTO=none

IPADDR=$pubIp

NETMASK=$pubMask

GATEWAY=$pubGW

USERCTL=no


EOF


cat >> /etc/modprobe.d/bonding.conf <<EOF

alias bond1 bonding

options bond1 miimon=100 mode=1

EOF

}

#创建bridge配置文件 修改bond配置文件 包括公网IP和私网IP子接口

create_bridge() {

create_eth

mv -f $confDir/ifcfg-bond1 $backConfDir 1>/dev/null 2>&1

mv -f $confDir/ifcfg-br0 $backConfDir 1>/dev/null 2>&1

rm -f /etc/libvirt/qemu/networks/autostart/default.xml

cat >> $confDir/ifcfg-bond1 <<EOF

DEVICE=bond1

ONBOOT=yes

BOOTPROTO=static

USERCTL=no

BRIDGE=br0

EOF

cat >> /etc/modprobe.d/bonding.conf <<EOF

alias bond1 bonding

options bond1 miimon=100 mode=1

EOF

cat >> $confDir/ifcfg-br0 <<EOF

DEVICE=br0

ONBOOT=yes

BOOTPROTO=static

IPADDR=$pubIp

NETMASK=$pubMask

GATEWAY=$pubGW

USERCTL=no

TYPE=Bridge

EOF

}

# 输入参数判断

if [ "$1" != "-t" ] && [ "$1" != "-b" ]; then

help

fi

if [ -z "$2" ]; then

help

fi


if [ -n "$2" ] && [ -z "$3" ] ; then

help

fi


if [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -z "$5" ]; then

help

fi

if [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ] && [ -z "$6" ]; then

help

fi

if [ -n "$2" ] && [ -n "$3" ]; then

ethm=$2

ethn=$3

pubIp=$4

pubMask=$5

pubGW=$6

checkEthmNum

checkEthnNum

checkIp

# 定义私网IP地址和子网掩码

#priIp=192.168.$(echo $pubIp | awk -F "." '{print $3"."$4}')

#priMask=255.255.0.0

fi

# 如果IP和子网掩码参数没有输入 将从ifcfg-ethm配置文件中读取

if [ -z "$4" ] && [ -z "$5" ] && [ -z "$6" ]; then

pubIp=$(grep "IPADDR" $confDir/ifcfg-eth$ethm | awk -F "=" '{print $2}')

pubMask=$(grep "NETMASK" $confDir/ifcfg-eth$ethm | awk -F "=" '{print $2}')

pubGW=$(grep "GATEWAY" $confDir/ifcfg-eth$ethm | awk -F "=" '{print $2}')

checkIp

# 定义私网IP地址和子网掩码

#priIp=192.168.$(echo $pubIp | awk -F "." '{print $3"."$4}')

#priMask=255.255.0.0

fi

if [ -n "$pubIp" ] && [ -n "$pubMask" ]; then

test -d $backConfDir || mkdir -p $backConfDir

if [ "$1" == "-b" ]; then

create_bridge

elif [ "$1" == "-t" ]; then

create_bond

fi

echo -e "\n create bond bonding succeed! \n please manual reboot network or server! \n"

else

echo -e "\n program error! please retry. \n"

exit 1

fi
