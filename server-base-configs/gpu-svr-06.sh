## FRONTEND NICs
ip link add bond0 type bond mode 802.3ad lacp_rate fast xmit_hash_policy layer3+4 miimon 100
ip link set eth17 down
ip link set eth18 down
ip link set eth17 master bond0
ip link set eth18 master bond0
ip link set bond0 up

# GPU
ip link add link bond0 name bond0.11 type vlan id 11
ip link set bond0.11 up
ip  addr add 10.0.2.3/24 dev bond0.11
ip route add 10.0.0.0/8 via 10.0.2.253

# Storage
ip link add link bond0 name bond0.21 type vlan id 21
ip link set bond0.21 up
ip  addr add 192.168.2.3/24 dev bond0.21
ip route add 192.168.0.0/16 via 192.168.2.253

# Internet
ip link add link bond0 name bond0.31 type vlan id 31
ip link set bond0.31 up
ip  addr add 172.16.2.3/24 dev bond0.31
ip route add 172.16.0.0/12 via 172.16.2.253


# PXE (service disabled by default)
# use this to test:
# ip link set dev eth17 nomaster
# ip link set dev eth18 nomaster
# ip link set dev eth17 up
# ip link set dev eth18 up
# ip addr add 100.127.255.6/24 dev eth17