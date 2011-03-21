#!/bin/bash

# You want to prevent remote hosts from spoofing incoming packets as if they 
# had come from your local machine. To do this, you need to turn on source 
# address verification in the kernel. Place the following code into a system 
# boot file (i.e., linked into the /etc/rc.d hierarchy) that executes before 
# any network devices are enabled. 
#
# (Based on "Linux Security Cookbook" - O'Relly; Chapter 2: "Firewalls with 
# iptables and ipchains")


IPV4CONF=/proc/sys/net/ipv4/conf
IPV6CONF=/proc/sys/net/ipv6/conf
SYSCTL=/etc/sysctl.conf


function procset {
    for f in $1/*/$2; do
        echo $f;
        echo $3 > $f;
    done;        
}

function confset {
    echo "net.$1.conf.all.$2=$3" >> $SYSCTL;
}

function set {
    procset $1 $3 $4;
    confset $2 $3 $4;
}


echo -n "Enabling source address verification... ";
set $IPV4CONF ipv4 rp_filter 1;
echo -n "Done.\n";

echo -n "Enabling secure redirects... ";
# Do not accept ICMP redirects (prevent MITM attacks)
set $IPV4CONF ipv4 accept_redirects 0;
set $IPV6CONF ipv6 accept_redirects 0;
# Accept ICMP redirects only for gateways listed in our default gateway list.
set $IPV4CONF ipv4 secure_redirects 1;
# Do not send ICMP redirects (we are not a router)
set $IPV4CONF ipv4 send_redirects 0;
# Do not accept IP source route packets (we are not a router)
set $IPV4CONF ipv4 accept_source_route 0;
set $IPV6CONF ipv6 accept_source_route 0;
echo "Done.\n";
