# AI fabric lab

This lab provides a AI Fabric reference topology using EDA, SR Linux and Containerlab.

Please read the [QUICKSTART.md](QUICKSTART.md).

## Platform & Prerequisites

- Containerlab — network emulation & SR Linux integration. https://containerlab.srlinux.dev/
- Clab-connector — topology-to-EDA linkage. https://github.com/eda-labs/clab-connector
- EDA Platform — orchestration, policy, and automation layer. https://docs.eda.dev/
- Linux OS (native or WSL) — host OS for tooling and scripts.

## Topology

 **Backend Network**
- BE Leaf nodes: 2 (2tier-beleaf-01..02) — Nokia SR Linux (ixrh5)
- BE Spine nodes: 1 (2tier-bespine-01) — Nokia SR Linux (ixrh5)
- GPU Servers: 2 (2tier-gpu-svr-01..02) — Linux frr:10.1.3 containers

 **Frontend Network**
- FE Leaf nodes: 2 (2tier-feleaf-01..02) — Nokia SR Linux (ixr-d3l)
- FE Spine nodes: 1 (2tier-fespine-01) — Nokia SR Linux (ixr-d3l)
- FE Juniper Node:1 (2tier-juniper) — Juniper_vjunos-switch
- FE Servers: 6 (2tier-fe-svr-03..08) — Linux frr:10.1.3 containers

![AI Fabric](/images/AI-fabric-topo.png)
```
