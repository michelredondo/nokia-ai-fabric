############### Mgmt
ip netns add mgmt
ip link add veth1 type veth peer name eth0 netns mgmt
ip netns exec mgmt ip link set lo up
ip netns exec mgmt ip link set dev eth0 address 00:00:10:01:01:06
ip netns exec mgmt ip link set eth0 up
ip netns exec mgmt ip addr add 10.1.1.6/24 dev eth0
ip netns exec mgmt ip route add default via 10.1.1.254 dev eth0

ip link add link eth1 name eth1.1 type vlan id 1
ip link set eth1.1 up

ip link add br-mgmt type bridge
ip link set br-mgmt up
ip link set veth1 up
ip link set veth1 master br-mgmt
ip link set eth1.1 master br-mgmt

############### Internet
ip netns add internet
ip link add veth2 type veth peer name eth0 netns internet
ip netns exec internet ip link set lo up
ip netns exec internet ip link set dev eth0 address 00:00:10:02:01:06
ip netns exec internet ip link set eth0 up
ip netns exec internet ip addr add 10.2.1.6/24 dev eth0
ip netns exec internet ip route add default via 10.2.1.254 dev eth0

ip link add link eth1 name eth1.2 type vlan id 2
ip link set eth1.2 up

ip link add br-internet type bridge
ip link set br-internet up
ip link set veth2 up
ip link set veth2 master br-internet
ip link set eth1.2 master br-internet

############### Private
ip netns add private
ip link add veth3 type veth peer name eth0 netns private
ip netns exec private ip link set lo up
ip netns exec private ip link set dev eth0 address 00:00:10:03:01:06
ip netns exec private ip link set eth0 up
ip netns exec private ip addr add 10.3.1.6/24 dev eth0
ip netns exec private ip route add default via 10.3.1.254 dev eth0

ip link add link eth1 name eth1.3 type vlan id 3
ip link set eth1.3 up

ip link add br-private type bridge
ip link set br-private up
ip link set veth3 up
ip link set veth3 master br-private
ip link set eth1.3 master br-private