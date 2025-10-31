#PXN#1
#======================================================================#
ip link add link eth1 name eth1.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:5:0:2/96 dev eth1.1
ip link set eth1.1 up

#PXN#2
#======================================================================#
ip link add link eth2 name eth2.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:6:0:2/96 dev eth2.1
ip link set eth2.1 up

#PXN#3
#======================================================================#
ip link add link eth3 name eth3.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:7:0:2/96 dev eth3.1
ip link set eth3.1 up

#PXN#4
#======================================================================#
ip link add link eth4 name eth4.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:8:0:2/96 dev eth4.1
ip link set eth4.1 up

#PXN#5
#======================================================================#
ip link add link eth5 name eth5.1 type vlan id 1
ip -6 addr add fd00:1:2:1:0:5:0:2/96 dev eth5.1
ip link set eth5.1 up

#PXN#6
#======================================================================#
ip link add link eth6 name eth6.1 type vlan id 1
ip -6 addr add fd00:1:2:1:0:6:0:2/96 dev eth6.1
ip link set eth6.1 up

#PXN#7
#======================================================================#
ip link add link eth7 name eth7.1 type vlan id 1
ip -6 addr add fd00:1:2:1:0:7:0:2/96 dev eth7.1
ip link set eth7.1 up

#PXN#8
#======================================================================#
ip link add link eth8 name eth8.1 type vlan id 1
ip -6 addr add fd00:1:2:1:0:8:0:2/96 dev eth8.1
ip link set eth8.1 up



# GPU0
ip route add table 1000 ::/0  via fd00:1:1:1:0:5:0:1
ip -6 rule add from fd00:1:1:1:0:5:0:2 lookup 1000

# GPU1
ip route add table 1001 ::/0  via fd00:1:1:1:0:6:0:1
ip -6 rule add from fd00:1:1:1:0:6:0:2 lookup 1001

# GPU2
ip route add table 1002 ::/0  via fd00:1:1:1:0:7:0:1
ip -6 rule add from fd00:1:1:1:0:7:0:2 lookup 1002

# GPU3
ip route add table 1003 ::/0  via fd00:1:1:1:0:8:0:1
ip -6 rule add from fd00:1:1:1:0:8:0:2 lookup 1003

# GPU4
ip route add table 1004 ::/0  via fd00:1:2:1:0:5:0:1
ip -6 rule add from fd00:1:2:1:0:5:0:2 lookup 1004

# GPU5
ip route add table 1005 ::/0  via fd00:1:2:1:0:6:0:1
ip -6 rule add from fd00:1:2:1:0:5:0:2 lookup 1005

# GPU6
ip route add table 1006 ::/0  via fd00:1:2:1:0:7:0:1
ip -6 rule add from fd00:1:2:1:0:5:0:2 lookup 1006

# GPU7
ip route add table 1007 ::/0  via fd00:1:2:1:0:8:0:1
ip -6 rule add from fd00:1:2:1:0:5:0:2 lookup 1007


#enable forward
sysctl -w net.ipv4.ip_forward=1  
sysctl -p

## VXLAN-BGP-EVPN Loop
ifconfig lo:255 10.13.58.32 netmask 255.255.255.255

## deactivate uplink interfaces
ip link set eth9 down
ip link set eth10 down
ip link set eth11 down
ip link set eth12 down


##################################
## root bridge and VXLAN device  ##
##################################

ip link add br0 type bridge vlan_filtering 1 vlan_default_pvid 0
ip link add vxlan0 type vxlan dstport 4789 local 10.13.58.32 nolearning external vnifilter
ip link set br0 addrgenmode none
ip link set vxlan0 addrgenmode none master br0

ip link set br0 address 00:00:10:13:58:32
ip link set vxlan0 address 00:00:10:13:58:32
ip link set br0 up
ip link set vxlan0 up

bridge link set dev vxlan0 vlan_tunnel on neigh_suppress on learning off

#############################
## ip-vrf mgmt  ##
#############################
ip link add vrf-mgmt type vrf table 101
ip link set vrf-mgmt up

#############################
## ip-vrf vrf-mgmt / l3vni 101 ##
#############################

bridge vlan add dev br0 vid 4001 self
bridge vlan add dev vxlan0 vid 4001
bridge vni add dev vxlan0 vni 101 
bridge vlan add dev vxlan0 vid 4001 tunnel_info id 101 
ip link add vrf-mgmt-br link br0 type vlan id 4001 
ip link set vrf-mgmt-br address 00:00:10:13:58:32 addrgenmode none 
ip link set vrf-mgmt-br master vrf-mgmt 
ip link set vrf-mgmt-br up
########################
## l2vni 1 (vrf-mgmt) ##
########################
bridge vlan add dev br0 vid 1 self
bridge vlan add dev vxlan0 vid 1
bridge vni add dev vxlan0 vni 1
bridge vlan add dev vxlan0 vid 1 tunnel_info id 1
ip link add vlan1 link br0 type vlan id 1
ip link set vlan1 master vrf-mgmt 
ip link set vlan1 addr 00:10:13:58:32:01 
ip addr add 10.1.1.254/24 dev vlan1 
ip link set vlan1 up

# Anycast MAC
#ip link add vlan1agw link vlan1 type macvlan mode private
#ip link set vlan1agw addr 00:00:5e:00:01:01  # same MAC on all VTEPs
#ip addr add 10.1.1.254/24 dev vlan1agw
#bridge fdb add 00:00:5e:00:01:01 dev br0 self local
#ip link set vlan1agw up

# Client connected to mgmt
ip netns add mgmt
ip link add veth1 type veth peer name eth0 netns mgmt
ip netns exec mgmt ip link set lo up
ip netns exec mgmt ip link set dev eth0 address 00:00:10:01:01:02
ip netns exec mgmt ip link set eth0 up
ip netns exec mgmt ip addr add 10.1.1.2/24 dev eth0
ip netns exec mgmt ip route add default via 10.1.1.254 dev eth0

ip link set veth1 master br0
bridge vlan add dev veth1 vid 1 pvid untagged
ip link set veth1 up

## mgmt Loop
ip link add name lo-mgmt type dummy
ip link set dev lo-mgmt master vrf-mgmt
ip addr add 10.13.57.32/32 dev lo-mgmt
ip link set lo-mgmt up

#############################
## ip-vrf internet  ##
#############################
ip link add vrf-internet type vrf table 102
ip link set vrf-internet up

#############################
## ip-vrf vrf-internet / l3vni 102 ##
#############################

bridge vlan add dev br0 vid 4002 self
bridge vlan add dev vxlan0 vid 4002
bridge vni add dev vxlan0 vni 102 
bridge vlan add dev vxlan0 vid 4002 tunnel_info id 102     
ip link add vrf-internet-br link br0 type vlan id 4002
ip link set vrf-internet-br address 00:00:10:13:58:32 addrgenmode none 
ip link set vrf-internet-br master vrf-internet 
ip link set vrf-internet-br up
########################
## l2vni 2 (vrf-internet) ##
########################
bridge vlan add dev br0 vid 2 self
bridge vlan add dev vxlan0 vid 2
bridge vni add dev vxlan0 vni 2
bridge vlan add dev vxlan0 vid 2 tunnel_info id 2
ip link add vlan2 link br0 type vlan id 2
ip link set vlan2 master vrf-mgmt 
ip link set vlan2 addr 00:10:13:58:32:02 
ip addr add 10.2.1.254/24 dev vlan2 
ip link set vlan2 up

# Anycast MAC
#ip link add vlan2agw link vlan2 type macvlan mode private
#ip link set vlan2agw addr 00:00:5e:00:01:01  # same MAC on all VTEPs
#ip addr add 10.2.1.254/24 dev vlan2agw
#bridge fdb add 00:00:5e:00:01:01 dev br0 self local
#ip link set vlan2agw up

# Client connected to internet
ip netns add internet
ip link add veth2 type veth peer name eth0 netns internet
ip netns exec internet ip link set lo up
ip netns exec internet ip link set dev eth0 address 00:00:10:02:01:02
ip netns exec internet ip link set eth0 up
ip netns exec internet ip addr add 10.2.1.2/24 dev eth0
ip netns exec internet ip route add default via 10.2.1.254 dev eth0

ip link set veth2 master br0
bridge vlan add dev veth2 vid 2 pvid untagged
ip link set veth2 up


#############################
## ip-vrf private  ##
#############################
ip link add vrf-private type vrf table 103
ip link set vrf-private up

#############################
## ip-vrf vrf-private / l3vni 103 ##
#############################

bridge vlan add dev br0 vid 4003 self
bridge vlan add dev vxlan0 vid 4003
bridge vni add dev vxlan0 vni 103 
bridge vlan add dev vxlan0 vid 4003 tunnel_info id 103 
ip link add vrf-private-br link br0 type vlan id 4003 
ip link set vrf-private-br address 00:00:10:13:58:32 addrgenmode none 
ip link set vrf-private-br master vrf-private 
ip link set vrf-private-br up
########################
## l2vni 3 (vrf-private) ##
########################
bridge vlan add dev br0 vid 3 self
bridge vlan add dev vxlan0 vid 3
bridge vni add dev vxlan0 vni 3
bridge vlan add dev vxlan0 vid 3 tunnel_info id 3
ip link add vlan3 link br0 type vlan id 3
ip link set vlan3 master vrf-mgmt 
ip link set vlan3 addr 00:10:13:58:32:03 
ip addr add 10.3.1.254/24 dev vlan3 
ip link set vlan3 up

# Anycast MAC
#ip link add vlan3agw link vlan1 type macvlan mode private
#ip link set vlan3agw addr 00:00:5e:00:01:01  # same MAC on all VTEPs
#ip addr add 10.3.1.254/24 dev vlan1agw
#bridge fdb add 00:00:5e:00:01:01 dev br0 self local
#ip link set vlan3agw up

# Client connected to private
ip netns add private
ip link add veth3 type veth peer name eth0 netns private
ip netns exec private ip link set lo up
ip netns exec private ip link set dev eth0 address 00:00:10:03:01:02
ip netns exec private ip link set eth0 up
ip netns exec private ip addr add 10.3.1.2/24 dev eth0
ip netns exec private ip route add default via 10.3.1.254 dev eth0

ip link set veth3 master br0
bridge vlan add dev veth3 vid 3 pvid untagged
ip link set veth3 up


## activate uplink interfaces
ip link set eth9 up
ip link set eth10 up
ip link set eth11 up
ip link set eth12 up