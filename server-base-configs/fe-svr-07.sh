ip link add link eth1 name eth1.10 type vlan id 10
ip addr add 10.1.2.7/24 dev eth1.10
ip link set dev eth1.10 address 00:00:10:01:02:07
ip link set eth1.10 up
ip route add 10.0.0.0/8 via 10.1.2.254 dev eth1.10