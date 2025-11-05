# Quickstart

This quickstart summarizes the deployment of a 2-tier AI Fabric with both Frontend and Backend networks.

## Topology summary (from `ai-fabric-2tier.yaml`)

 **Backend Network**
- BE Leaf nodes: 2 (2tier-beleaf-01..02) — Nokia SR Linux (ixrh5)
- BE Spine nodes: 1 (2tier-bespine-01) — Nokia SR Linux (ixrh5)
- GPU Servers: 2 (2tier-gpu-svr-01..02) — Linux frr:10.1.3 containers

 **Frontend Network**
- FE Leaf nodes: 2 (2tier-feleaf-01..02) — Nokia SR Linux (ixr-d3l)
- FE Spine nodes: 1 (2tier-fespine-01) — Nokia SR Linux (ixr-d3l)
- FE Juniper Node:1 (2tier-juniper) — Juniper_vjunos-switch
- FE Servers: 6 (2tier-fe-svr-03..08) — Linux frr:10.1.3 containers

## Deploy steps

1. Check deployment of EDA

   - Follow EDA Installation Quickstart https://docs.eda.dev/25.8/getting-started/try-eda/
   - As this lab uses Containerlab nodes an EDA license is required https://docs.eda.dev/25.8/user-guide/containerlab-integration/#installing-eda

2. Deploy containerlab topology:

   - `clab deploy -t ai-fabric-2tier.yaml`

3. Wait for nodes (sleep 45 seconds).

4. Create EDA namespaces:

   - `kubectl apply -f eda_manifests_2tier/BE/namespace.yaml`
   - `kubectl apply -f eda_manifests_2tier/FE/namespace.yaml`

5. Integrate Containerlab nodes with EDA:

   - `kubectl apply -f connector-clab-manifests/`

6. Wait for nodes to be discovered and synced in EDA (90 seconds):

   - In EDA UI, select namespace( ai-fabric-be/ai-fabric-fe), and check "Nodes" in left panel
   - Using kubectl/edactl: `kubectl -n ai-fabric-be get  toponode`, `kubectl -n ai-fabric-fe get toponode`

7. Apply Backend resource manifests (IP/index pools, forwarding classes, queues):

   - `kubectl apply -f eda_manifests_2tier/BE/ip-allocation-pools.yaml`
   - `kubectl apply -f eda_manifests_2tier/BE/index-allocation-pools.yaml`
   - `kubectl apply -f eda_manifests_2tier/BE/forwarding-classes.yaml`
   - `kubectl apply -f eda_manifests_2tier/BE/queues.yaml`
   
8. Apply Backend AI Fabric Rail-only manifest:

   - `kubectl apply -f eda_manifests_2tier/BE/ai-fabric-rail-optimized.yaml`

9. Wait for Backend interfaces & patch them: ( `./scripts/patch_dot1q_be.sh`).

10. Add leaf labels to Backend `toponode` objects and run `./scripts/labels-2tier-be.sh` to label EDA objects.

11. Apply Backend Configlets:
   - `kubectl apply -f eda_manifests_2tier/BE/configlets/`

12. Apply Frontend resource manifests (IP/index pools...):
   - `kubectl apply -f eda_manifests_2tier/FE/asn-pool.yaml`
   - `kubectl apply -f eda_manifests_2tier/FE/ip-allocation-pools.yaml`
   - `kubectl apply -f eda_manifests_2tier/FE/indices.yaml`
   - `kubectl apply -f eda_manifests_2tier/FE/FE-fabric.yml`
   - `kubectl apply -f eda_manifests_2tier/FE/overlay-networks.yaml`

13. Wait for Frontend interfaces & patch them: ( `./scripts/patch_dot1q_fe.sh` ).

14. Apply Frontend resource manifests (BGP sessions with GPU-servers and Juniper switch):

   - `kubectl apply -f eda_manifests_2tier/FE/gpu-servers-bgp-lla-sessions.yaml`
   - `kubectl apply -f eda_manifests_2tier/FE/gpu-servers-bgp-evpn-sessions.yaml`
   - `kubectl apply -f eda_manifests_2tier/FE/juniper-bgp-lla-sessions.yaml`
   - `kubectl apply -f eda_manifests_2tier/FE/juniper-bgp-evpn-sessions.yaml`

   We can check the status of BGP sessions with `edactl -n ai-fabric-fe get  defaultbgppeers.protocols.eda.nokia.com` 

15. Add leaf labels to Frontend `toponode` objects and run `./scripts/labels-2tier-fe.sh` to label EDA objects.

16. Apply Frontend Configlets:
   - `kubectl apply -f eda_manifests_2tier/FE/configlets/`

17. Run traffic tests 

## Backend Traffic tests

EDA defines the Backend IPv6 addresing scheme using this rule:
```bash
fd00:{stripe_id}:{leafnode_index}:{slot_num}:{connector_num}:{intf_num}::1/96
```
which translates into this backend IPv6 addresing in GPU nodes: 

```bash
server1-GPU0: fd00:1:1:1:0:1:0:2/96 -> BE-Leaf1
server1-GPU1: fd00:1:1:1:0:2:0:2/96 -> BE-Leaf1
server1-GPU2: fd00:1:1:1:0:3:0:2/96 -> BE-Leaf1
server1-GPU3: fd00:1:1:1:0:4:0:2/96 -> BE-Leaf1
server1-GPU4: fd00:1:2:1:0:1:0:2/96 -> BE-Leaf2
server1-GPU5: fd00:1:2:1:0:2:0:2/96 -> BE-Leaf2
server1-GPU6: fd00:1:2:1:0:3:0:2/96 -> BE-Leaf2
server1-GPU7: fd00:1:2:1:0:4:0:2/96 -> BE-Leaf2

server2-GPU0: fd00:1:1:1:0:5:0:2/96 -> BE-Leaf1
server2-GPU1: fd00:1:1:1:0:6:0:2/96 -> BE-Leaf1
server2-GPU2: fd00:1:1:1:0:7:0:2/96 -> BE-Leaf1
server2-GPU3: fd00:1:1:1:0:8:0:2/96 -> BE-Leaf1
server2-GPU4: fd00:1:2:1:0:5:0:2/96 -> BE-Leaf2
server2-GPU5: fd00:1:2:1:0:6:0:2/96 -> BE-Leaf2
server2-GPU6: fd00:1:2:1:0:7:0:2/96 -> BE-Leaf2
server2-GPU7: fd00:1:2:1:0:8:0:2/96 -> BE-Leaf2
```
The backend topology defined in `eda_manifests_2tier/BE/ai-fabric-rail-optimized.yaml` enforces isolation, allowing connectivity only among GPUs within the same rank:

<img src="/images/Backend_optimized.png" width="160">

Note that in this lab, backend traffic isolation is not enforced at the kernel level, so intra-server GPU communication will always function. However, we can verify that server1-GPU0 only connects to server2-GPU0:

```bash
# ping from server1-GPU0 from to server2-GPU0
docker exec -it 2tier-gpu-svr-01 ping fd00:1:1:1:0:5:0:2 -I  fd00:1:1:1:0:1:0:2 -c1
PING fd00:1:1:1:0:5:0:2 (fd00:1:1:1:0:5:0:2) from fd00:1:1:1:0:1:0:2: 56 data bytes
64 bytes from fd00:1:1:1:0:5:0:2: seq=0 ttl=63 time=0.323 ms

--- fd00:1:1:1:0:5:0:2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.323/0.323/0.323 ms

# ping from server1-GPU0 from to server2-GPU1
docker exec -it 2tier-gpu-svr-01 ping fd00:1:1:1:0:6:0:2 -I  fd00:1:1:1:0:1:0:2 -c1
PING fd00:1:1:1:0:6:0:2 (fd00:1:1:1:0:6:0:2) from fd00:1:1:1:0:1:0:2: 56 data bytes

--- fd00:1:1:1:0:6:0:2 ping statistics ---
1 packets transmitted, 0 packets received, 100% packet loss
```

Two other multitenancy topologies can be tested. We only need to apply in EDA the correct labels to the interfaces:

 - 2 x Tenant topology: (`./scripts/labels-2tier-be_two_tenants.sh`):
 
<img src="/images/Backend_2xTenants.png" width="160">

 - 1 x Tenant topology: (`./scripts/labels-2tier-be_single_tenant.sh`):
 
<img src="/images/Backend_single_tenant.png" width="160">



## Frontend Traffic tests

The frontend fabric supports VXLAN-EVPN. GPU servers can connect natively using overlay SDN solutions, such as Open Virtual Network (OVN). In this lab environment, FRR is used to emulate this integration. The topology consists of three isolated Layer 3 EVPN networks simulating management, internet, and private in-band connectivity.
These three networks are isolated in the GPUs by using namespaces:

```bash
# ping from gpu-srv-01 to gpu-srv-01 in mgmt network 
docker exec -it 2tier-gpu-svr-01 ip netns exec mgmt ping 10.1.1.2 -c1
PING 10.1.1.2 (10.1.1.2): 56 data bytes
64 bytes from 10.1.1.2: seq=0 ttl=64 time=1.328 ms

--- 10.1.1.2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 1.328/1.328/1.328 ms

# ping from gpu-srv-01 to baremetal server connected to leaf2 in mgmt network
docker exec -it 2tier-gpu-svr-01 ip netns exec mgmt ping 10.1.2.3 -c1
PING 10.1.2.3 (10.1.2.3): 56 data bytes
64 bytes from 10.1.2.3: seq=0 ttl=63 time=0.706 ms

--- 10.1.2.3 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.706/0.706/0.706 ms

# ping from gpu-srv-01 to baremetal server connected to juniper leaf 
docker exec -it 2tier-gpu-svr-01 ip netns exec mgmt ping 10.1.2.7 -c1
PING 10.1.2.7 (10.1.2.7): 56 data bytes
64 bytes from 10.1.2.7: seq=0 ttl=63 time=3.467 ms

--- 10.1.2.7 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 3.467/3.467/3.467 ms

# ping from frontend-srv-05 to gpu-srv-01 mgmt loop address 
docker exec -it 2tier-fe-svr-05 ip netns exec mgmt ping 10.13.57.31 -c1
PING 10.13.57.31 (10.13.57.31): 56 data bytes
64 bytes from 10.13.57.31: seq=0 ttl=63 time=0.859 ms

--- 10.13.57.31 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.859/0.859/0.859 ms
```

##  Removing the lab

To remove the lab, remove the namespaces we have created and destroy the containerlab topology:
```
edactl delete namespace ai-fabric-be
edactl delete namespace ai-fabric-fe
clab destroy -t ai-fabric-2tier.yaml --cleanup
```


## 🛰️ Telemetry (Optional)

### How to Install the Telemetry Dashboard

> **Note:**
> The following scripts and approach are based on:
> [https://github.com/eda-labs/eda-telemetry-lab.git](https://github.com/eda-labs/eda-telemetry-lab.git)

---

### ✅ Requirements

- **EDA version:** `25.8.2`
- **kubectl**
  (You may copy from the EDA playground clone project: `~/playground/tools/`)
- **helm**
  (You may copy from the EDA playground clone project: `~/playground/tools/`)
- **Internet access** to `ghcr.io` images
- **Pre-installed EDA backend and frontend objects** (mainly namespaces)

---

### 🧩 Verify EDA Installation

Before proceeding with the telemetry lab deployment, ensure you have a working EDA installation.
You can verify it by running:

```bash
kubectl -n eda-system get engineconfig engine-config \
-o jsonpath='{.status.run-status}{"\n"}'
```
## ⚙️ Installation Steps

1. Change directory to the telemetry folder:
   ```bash
   cd ./telemetry
   ```
2. Execute the initialization script:
   ```bash
   EDA_URL=https://test.eda.com:9443 ./init.sh
   ```
3. Wait for successful completion of the deployment process.

4. Once completed, access the Grafana and Prometheus dashboards using the following URLs:

  - **Grafana:**
  https://test.eda.com:9443/core/httpproxy/v1/grafana/d/Telemetry_Playground/

  - **Prometheus:**
  https://test.eda.com:9443/core/httpproxy/v1/prometheus/query

5.- End.

## ⚙️ Removing the Telemetry Stack
   ```bash
   helm uninstall telemetry-stack -n eda-telemetry
   ```

# How to Create Your Own Grafana Container Imagei(optional)

If you need to make changes to your Grafana dashboard and want to automate the process, follow the steps below                                            to build and deploy your customized Grafana container image.

---

## 1. Change Directory to the Image Folder
```bash
cd ./image
```

---

## 2. Add Your Grafana Dashboard JSON Model
Copy and paste your Grafana dashboard JSON model file (from **Dashboard → Settings → JSON Model**) into:
```
./image/files/st.json
```

---

## 3. Build a New Grafana Container Image
Create a new Docker image with your desired tag:
```bash
docker build -t grafana/grafana:test .
```

---

## 4. Keep the Image Locally or Push It to a Registry

### Option A: Local (Kind Cluster)
If you are using **Kind**, you may need to load the image into your Kubernetes cluster:
```bash
kind load docker-image grafana/grafana:test --name=eda-demo
```

### Option B: GitHub Container Registry
If you prefer to push the image to GitHub’s registry, run:
```bash
docker tag grafana/grafana:test ghcr.io/guillermomm/grafana/grafana:12.0.2
docker push ghcr.io/guillermomm/grafana/grafana:12.0.2
```

---

## 5. Update the Helm Deployment Image
Modify the Grafana deployment file:
```
.telemetry/charts/telemetry-stack/templates/deployment.yaml
```

Update the image section as shown below:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  labels:
    app: telemetry-stack
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      securityContext:
        fsGroup: 472
        runAsUser: 472
        runAsGroup: 472
      containers:
        - name: grafana
          # image: grafana/grafana:test
          image: ghcr.io/guillermomm/grafana/grafana:12.0.2
          imagePullPolicy: {{ .Values.imagePullPolicy }}
```

---

## 6. Reinstall the Telemetry Stack
Uninstall and reinstall your telemetry stack to apply the changes:
```bash
helm uninstall telemetry-stack -n eda-telemetry
EDA_URL=https://test.eda.com:9443 ./init.sh
```

---

## 7. Done!
Your custom Grafana container image should now be running with your updated dashboard configuration.


