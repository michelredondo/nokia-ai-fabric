# Nokia AI Fabric

A Containerlab based emulation of a Nokia AI fabric network using SR Linux. The topology models separate frontend and backend fabrics along with GPU, storage, and Internet facing services.

## Platform & Prerequisites

- **Containerlab** – Network emulation and SR Linux integration.
  - https://containerlab.srlinux.dev/
- **Linux** (native or WSL) – Host operating system for running Containerlab and supporting scripts.

## Topology

![Topology](images/ai-fabric-srl-topo.svg)

### Backend Fabric

- **BE Leaf nodes:** 2 (`beleaf-01`–`beleaf-02`) — Nokia SR Linux (IXR-H5-64)
- **BE Spine nodes:** 1 (`bespine-01`) — Nokia SR Linux (IXR-H5-64)
- **GPU Servers:** 6 (`gpu-svr-01`–`gpu-svr-06`) — Linux FRR 10.1.3 containers

### Frontend Fabric

- **FE Leaf nodes:** 6 (`feleaf-01`–`feleaf-06`) — Nokia SR Linux (IXR-H5-32)
- **FE Border Leaf nodes:** 2 (`febleaf-07`–`febleaf-08`) — Nokia SR Linux (IXR-D5)
- **FE Border Leaf nodes (IXR-X4):** 2 (`febleaf-09`–`febleaf-10`) — Nokia SR Linux (IXR-X4)
- **FE Spine nodes:** 2 (`fespine-01`–`fespine-02`) — Nokia SR Linux (IXR-H5-64)
- **GPU Servers:** 7 (`gpu-svr-01`–`gpu-svr-06`-`test-svr-01`) — Linux FRR 10.1.3 containers
- **Storage Servers:** 2 (`storage-svr-01`–`storage-svr-02`) — Linux FRR 10.1.3 containers
- **Internet Server:** 1 (`internet-svr-01`) — Linux FRR 10.1.3 container
- **PXE-BOOT Server:** 1 (`pxe-svr-01`) — Linux FRR 10.1.3 container

## Frontend Services

The topology simulates two tenants. Each tenant contains three GPU servers:

- **TENANT A:** `gpu-svr-01`, `gpu-svr-03`, `gpu-svr-05`, `test-svr-01 (L3-MH)`
- **TENANT B:** `gpu-svr-02`, `gpu-svr-04`, `gpu-svr-06`

Each server is dual-homed to a pair of leaf switches using an EVPN Ethernet Segment (ES) for active-active multihoming. `test-svr-01` uses L3-MH as per approach 2 in draft-ietf-bess-evpn-l3mh-proto.

Four VRFs are provided:

- **GPU VRF (per tenant):** GPU servers belonging to the same tenant can communicate with each other. Communication between tenants is not permitted.
- **STORAGE VRF (per tenant):** GPU servers can communicate with each other and access the shared storage servers (`192.168.255.1` and `192.168.255.2`). Communication between tenants is not permitted.
- **INTERNET VRF:** All GPU servers can communicate regardless of tenant. Internet connectivity is simulated by `internet-svr-01` (`172.16.255.255`). Internet server is conected to border leaf switches `febleaf-07` and `febleaf-08`.
- **PXE Boot MAC-VRF:** All GPU servers can communicate with the `pxe-svr-01` (`100.127.255.254`) server. GPU servers use LACP fallback on the first member of their bond (`eth17`), allowing connectivity to the PXE server before the bond is fully established. This MAC-VRF simulates the PXE boot process. 

The following table summarizes how the services are deployed in the fabric.

![Service deployment](images/client-services.png)
