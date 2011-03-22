#!/bin/bash

IT=/sbin/iptables #iptables binary
WAN=eth0 # wan interface

# flush existent rules

$IT -F INPUT 
$IT -F OUTPUT
$IT -F FORWARD

# enabling outgoing HTTP traffic

$IP -A OUTPUT -p tcp -i $WAN --dport www -j ACCEPT

# enabling outgoing SSH traffic

# enabling all localhost traffic

$IP -A INPUT -i lo -j ACCEPT
$IP -A OUTPUT -i lo -j ACCEPT
$IP -A FORWARD -i lo -j ACCEPT


# last rules: denny all traffic

$IT -A INPUT -j REJECT
$IT -A OUTPUT -j REJECT
$IT -A FORWARD -j REJECT
