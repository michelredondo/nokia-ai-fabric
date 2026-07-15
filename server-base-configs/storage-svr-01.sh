## FRONTEND NICs
ip link add bond0 type bond mode 802.3ad lacp_rate fast xmit_hash_policy layer3+4 miimon 100
ip link set eth1 down
ip link set eth2 down
ip link set eth1 master bond0
ip link set eth2 master bond0
ip link set bond0 up


# Storage
ip link add link bond0 name bond0.1 type vlan id 1
ip link set bond0.1 up
ip  addr add 192.168.255.1/24 dev bond0.1
ip route add 192.168.0.0/16 via 192.168.255.253