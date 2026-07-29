## FRONTEND NICs
ip link add link eth1 name eth1.1 type vlan id 1
ip link set eth1.1 up

ip link add link eth2 name eth2.1 type vlan id 1
ip link set eth2.1 up


# STORAGE LOOP
ip addr add 192.168.255.2/32 dev lo
