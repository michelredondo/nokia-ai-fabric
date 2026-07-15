## BACKEND NICs
#PXN#1
#======================================================================#
ip link add link eth1 name eth1.1 type vlan id 1
ip -6 addr add fd00:1:1:1:1:1:0:2/96 dev eth1.1
ip link set eth1.1 up

ip link add link eth2 name eth2.1 type vlan id 1
ip -6 addr add fd00:1:1:1:1:2:0:2/96 dev eth2.1
ip link set eth2.1 up

#PXN#2
#======================================================================#
ip link add link eth3 name eth3.1 type vlan id 1
ip -6 addr add fd00:1:1:1:2:1:0:2/96 dev eth3.1
ip link set eth3.1 up

ip link add link eth4 name eth4.1 type vlan id 1
ip -6 addr add fd00:1:1:1:2:2:0:2/96 dev eth4.1
ip link set eth4.1 up

#PXN#3
#======================================================================#
ip link add link eth5 name eth5.1 type vlan id 1
ip -6 addr add fd00:1:1:1:3:1:0:2/96 dev eth5.1
ip link set eth5.1 up

ip link add link eth6 name eth6.1 type vlan id 1
ip -6 addr add fd00:1:1:1:3:2:0:2/96 dev eth6.1
ip link set eth6.1 up

#PXN#4
#======================================================================#
ip link add link eth7 name eth7.1 type vlan id 1
ip -6 addr add fd00:1:1:1:4:1:0:2/96 dev eth7.1
ip link set eth7.1 up

ip link add link eth8 name eth8.1 type vlan id 1
ip -6 addr add fd00:1:1:1:4:2:0:2/96 dev eth8.1
ip link set eth8.1 up

#PXN#5
#======================================================================#
ip link add link eth9 name eth9.1 type vlan id 1
ip -6 addr add fd00:1:2:1:1:1:0:2/96 dev eth9.1
ip link set eth9.1 up

ip link add link eth10 name eth10.1 type vlan id 1
ip -6 addr add fd00:1:2:1:1:2:0:2/96 dev eth10.1
ip link set eth10.1 up

#PXN#6
#======================================================================#
ip link add link eth11 name eth11.1 type vlan id 1
ip -6 addr add fd00:1:2:1:2:1:0:2/96 dev eth11.1
ip link set eth11.1 up

ip link add link eth12 name eth12.1 type vlan id 1
ip -6 addr add fd00:1:2:1:2:2:0:2/96 dev eth12.1
ip link set eth12.1 up

#PXN#7
#======================================================================#
ip link add link eth13 name eth13.1 type vlan id 1
ip -6 addr add fd00:1:2:1:3:1:0:2/96 dev eth13.1
ip link set eth13.1 up

ip link add link eth14 name eth14.1 type vlan id 1
ip -6 addr add fd00:1:2:1:3:2:0:2/96 dev eth14.1
ip link set eth14.1 up

#PXN#8
#======================================================================#
ip link add link eth15 name eth15.1 type vlan id 1
ip -6 addr add fd00:1:2:1:4:1:0:2/96 dev eth15.1
ip link set eth15.1 up

ip link add link eth16 name eth16.1 type vlan id 1
ip -6 addr add fd00:1:2:1:4:2:0:2/96 dev eth16.1
ip link set eth16.1 up


# GPU0-port1
ip route add table 1000 ::/0  via fd00:1:1:1:1:1:0:1
ip -6 rule add from fd00:1:1:1:1:1:0:2 lookup 1000
# GPU0-port2
ip route add table 1001 ::/0  via fd00:1:1:1:1:2:0:1
ip -6 rule add from fd00:1:1:1:1:2:0:2 lookup 1001

# GPU1-port1
ip route add table 1002 ::/0  via fd00:1:1:1:2:1:0:1
ip -6 rule add from fd00:1:1:1:2:1:0:2 lookup 1002
# GPU1-port2
ip route add table 1003 ::/0  via fd00:1:1:1:2:2:0:1
ip -6 rule add from fd00:1:1:1:2:2:0:2 lookup 1003

# GPU2-port1
ip route add table 1004 ::/0  via fd00:1:1:1:3:1:0:1
ip -6 rule add from fd00:1:1:1:3:1:0:2 lookup 1004
# GPU2-port2
ip route add table 1005 ::/0  via fd00:1:1:1:3:2:0:1
ip -6 rule add from fd00:1:1:1:3:2:0:2 lookup 1005

# GPU3-port1
ip route add table 1006 ::/0  via fd00:1:1:1:4:1:0:1
ip -6 rule add from fd00:1:1:1:4:1:0:2 lookup 1006
# GPU3-port2
ip route add table 1007 ::/0  via fd00:1:1:1:4:2:0:1
ip -6 rule add from fd00:1:1:1:4:2:0:2 lookup 1007

# GPU4-port1
ip route add table 1008 ::/0  via fd00:1:2:1:1:1:0:1
ip -6 rule add from fd00:1:2:1:1:1:0:2 lookup 1008
# GPU4-port2
ip route add table 1009 ::/0  via fd00:1:2:1:1:2:0:1
ip -6 rule add from fd00:1:2:1:1:2:0:2 lookup 1009

# GPU5-port1
ip route add table 1010 ::/0  via fd00:1:2:1:2:1:0:1
ip -6 rule add from fd00:1:2:1:2:1:0:2 lookup 1010
# GPU5-port2
ip route add table 1011 ::/0  via fd00:1:2:1:2:2:0:1
ip -6 rule add from fd00:1:2:1:2:2:0:2 lookup 1011

# GPU6-port1
ip route add table 1012 ::/0  via fd00:1:2:1:3:1:0:1
ip -6 rule add from fd00:1:2:1:3:1:0:2 lookup 1012
# GPU6-port2
ip route add table 1013 ::/0  via fd00:1:2:1:3:2:0:1
ip -6 rule add from fd00:1:2:1:3:2:0:2 lookup 1013

# GPU7-port1
ip route add table 1014 ::/0  via fd00:1:2:1:4:1:0:1
ip -6 rule add from fd00:1:2:1:4:1:0:2 lookup 1014
# GPU7-port2
ip route add table 1015 ::/0  via fd00:1:2:1:4:2:0:1
ip -6 rule add from fd00:1:2:1:4:2:0:2 lookup 1015

## FRONTEND NICs
ip link add bond0 type bond mode 802.3ad lacp_rate fast xmit_hash_policy layer3+4 miimon 100
ip link set eth17 down
ip link set eth18 down
ip link set eth17 master bond0
ip link set eth18 master bond0
ip link set bond0 up

# GPU
ip link add link bond0 name bond0.10 type vlan id 10
ip link set bond0.10 up
ip  addr add 10.0.1.1/24 dev bond0.10
ip route add 10.0.0.0/8 via 10.0.1.253

# Storage
ip link add link bond0 name bond0.20 type vlan id 20
ip link set bond0.20 up
ip  addr add 192.168.1.1/24 dev bond0.20
ip route add 192.168.0.0/16 via 192.168.1.253

# Internet
ip link add link bond0 name bond0.30 type vlan id 30
ip link set bond0.30 up
ip  addr add 172.16.1.1/24 dev bond0.30
ip route add 172.16.0.0/12 via 172.16.1.253