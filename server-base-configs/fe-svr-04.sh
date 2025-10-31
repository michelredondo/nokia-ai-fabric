ip link add link eth1 name eth1.11 type vlan id 11
ip addr add 10.1.2.4/24 dev eth1.11
ip link set dev eth1.11 address 00:00:10:01:02:04
ip link set eth1.11 up
ip route add 10.0.0.0/8 via 10.1.2.254 dev eth1.11