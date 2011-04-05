#!/bin/sh

# Basic firewall for a single machine using iptables.
# Source: http://www.pizon.org/articles/building-a-linux-firewall-with-iptables.html

IT=/sbin/iptables # binary

echo -n "Applying firewall politics... "

# flush existent rules

$IT --flush

# default polices (deny-by-default)

$IT --policy INPUT DROP
$IT --policy OUTPUT DROP
$IT --policy FORWARD DROP

# enable loopback traffic

$IT --append INPUT -i lo -j ACCEPT
$IT --append OUTPUT -o lo -j ACCEPT

# allow INPUT for established connections

$IT --append INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# allow OUTPUT for established and new connections 

$IT --append OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

echo -n "Done.\n"
