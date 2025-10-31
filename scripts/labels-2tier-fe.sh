#!/bin/bash

# Add labels to objects

kubectl label interfaces 2tier-feleaf-01-ethernet-1-17 -n ai-fabric-fe eda.nokia.com/vrf-mgmt=true
kubectl label interfaces 2tier-feleaf-02-ethernet-1-17 -n ai-fabric-fe eda.nokia.com/vrf-mgmt=true

kubectl label interfaces 2tier-feleaf-01-ethernet-1-17 -n ai-fabric-fe eda.nokia.com/vrf-internet=true
kubectl label interfaces 2tier-feleaf-02-ethernet-1-17 -n ai-fabric-fe eda.nokia.com/vrf-internet=true

kubectl label interfaces 2tier-feleaf-01-ethernet-1-17 -n ai-fabric-fe eda.nokia.com/vrf-private=true
kubectl label interfaces 2tier-feleaf-02-ethernet-1-17 -n ai-fabric-fe eda.nokia.com/vrf-private=true

kubectl label interfaces 2tier-feleaf-01-ethernet-1-16 -n ai-fabric-fe eda.nokia.com/vrf-mgmt2=true
kubectl label interfaces 2tier-feleaf-02-ethernet-1-16 -n ai-fabric-fe eda.nokia.com/vrf-mgmt2=true