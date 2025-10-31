#!/bin/bash

NAMESPACE="ai-fabric-fe"
PATCH='{"spec":{"encapType":"dot1q"}}'
LABEL_KEY="eda.nokia.com/role"
LABEL_VALUE="edge"

echo "Patching interfaces:"
kubectl -n "$NAMESPACE" patch interface 2tier-feleaf-01-ethernet-1-16 --type=merge -p "$PATCH"
kubectl -n "$NAMESPACE" patch interface 2tier-feleaf-01-ethernet-1-17 --type=merge -p "$PATCH"
kubectl -n "$NAMESPACE" patch interface 2tier-feleaf-02-ethernet-1-16 --type=merge -p "$PATCH"
kubectl -n "$NAMESPACE" patch interface 2tier-feleaf-02-ethernet-1-17 --type=merge -p "$PATCH"
kubectl -n "$NAMESPACE" patch interface 2tier-fespine-01-ethernet-1-31 --type=merge -p "$PATCH"

echo "Patching process complete."