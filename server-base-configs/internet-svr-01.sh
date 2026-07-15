## FRONTEND NICs
ip link add link eth1 name eth1.1 type vlan id 1
ip addr add 172.16.255.1/31 dev eth1.1
ip link set eth1.1 up

ip link add link eth2 name eth2.1 type vlan id 1
ip addr add 172.16.255.3/31 dev eth2.1
ip link set eth2.1 up

# Loop Internet
#ifconfig lo:255 172.16.255.255 netmask 255.255.255.255
ip addr add 172.16.255.255/32 dev lo