#!/bin/bash

# Add labels to objects

# Backend Leaf
for i in {1..2}; do
    kubectl label --overwrite=true toponodes 2tier-beleaf-0$i -n ai-fabric-be eda.nokia.com/stripe-id=stripe1
done

# Backend Spine
for i in {1..1}; do
    kubectl label --overwrite=true toponodes 2tier-bespine-0$i -n ai-fabric-be eda.nokia.com/stripeconn-id=stripeconn01
done

# Backend Edge port label assignment

#VRF1
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-1-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster1
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-5-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster1
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-1-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster1
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-5-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster1

#VRF2
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-2-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster2
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-6-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster2
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-2-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster2
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-6-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster2

#VRF3
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-3-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster3
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-7-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster3
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-3-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster3
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-7-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster3

#VRF4
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-4-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster4
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-8-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster4
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-4-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster4
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-8-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster4

#VRF5
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-1-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster5
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-5-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster5
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-1-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster5
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-5-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster5

#VRF6
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-2-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster6
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-6-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster6
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-2-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster6
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-6-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster6

#VRF7
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-3-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster7
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-7-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster7
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-3-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster7
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-7-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster7

#VRF8
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-4-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster8
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-8-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster8
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-4-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster8
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-8-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster8

# Spine-Leaf Backend (Stripe Connector)
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-1-2tier-beleaf-01-e1-33   -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-2-2tier-beleaf-01-e1-34   -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-3-2tier-beleaf-01-e1-35   -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-4-2tier-beleaf-01-e1-36   -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-5-2tier-beleaf-01-e1-37   -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-6-2tier-beleaf-01-e1-38   -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-7-2tier-beleaf-01-e1-39   -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-8-2tier-beleaf-01-e1-40   -n ai-fabric-be eda.nokia.com/role=interSwitchBE
#kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-9-2tier-beleaf-01-e1-41   -n ai-fabric-be eda.nokia.com/role=interSwitchBE
#kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-10-2tier-beleaf-01-e1-42  -n ai-fabric-be eda.nokia.com/role=interSwitchBE
#kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-11-2tier-beleaf-01-e1-43  -n ai-fabric-be eda.nokia.com/role=interSwitchBE
#kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-12-2tier-beleaf-01-e1-44  -n ai-fabric-be eda.nokia.com/role=interSwitchBE

kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-33-2tier-beleaf-02-e1-33 -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-34-2tier-beleaf-02-e1-34 -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-35-2tier-beleaf-02-e1-35 -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-36-2tier-beleaf-02-e1-36 -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-37-2tier-beleaf-02-e1-37 -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-38-2tier-beleaf-02-e1-38 -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-39-2tier-beleaf-02-e1-39 -n ai-fabric-be eda.nokia.com/role=interSwitchBE
kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-40-2tier-beleaf-02-e1-40 -n ai-fabric-be eda.nokia.com/role=interSwitchBE
#kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-41-2tier-beleaf-02-e1-41 -n ai-fabric-be eda.nokia.com/role=interSwitchBE
#kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-42-2tier-beleaf-02-e1-42 -n ai-fabric-be eda.nokia.com/role=interSwitchBE
#kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-43-2tier-beleaf-02-e1-43 -n ai-fabric-be eda.nokia.com/role=interSwitchBE
#kubectl label --overwrite=true topolinks 2tier-bespine-01-e1-44-2tier-beleaf-02-e1-44 -n ai-fabric-be eda.nokia.com/role=interSwitchBE
