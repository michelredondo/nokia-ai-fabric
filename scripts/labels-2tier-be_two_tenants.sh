#VRF1
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster1
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster1

kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-3 -n ai-fabric-be eda.nokia.com/tenant=gpucluster1
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-4 -n ai-fabric-be eda.nokia.com/tenant=gpucluster1

kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-5 -n ai-fabric-be eda.nokia.com/tenant=gpucluster1
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-6 -n ai-fabric-be eda.nokia.com/tenant=gpucluster1

kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-7 -n ai-fabric-be eda.nokia.com/tenant=gpucluster1
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-8 -n ai-fabric-be eda.nokia.com/tenant=gpucluster1


#VRF2
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-5 -n ai-fabric-be eda.nokia.com/tenant=gpucluster2
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-6 -n ai-fabric-be eda.nokia.com/tenant=gpucluster2

kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-7 -n ai-fabric-be eda.nokia.com/tenant=gpucluster2
kubectl label --overwrite=true interfaces 2tier-beleaf-01-ethernet-1-8 -n ai-fabric-be eda.nokia.com/tenant=gpucluster2

kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-1 -n ai-fabric-be eda.nokia.com/tenant=gpucluster2
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-2 -n ai-fabric-be eda.nokia.com/tenant=gpucluster2

kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-3 -n ai-fabric-be eda.nokia.com/tenant=gpucluster2
kubectl label --overwrite=true interfaces 2tier-beleaf-02-ethernet-1-4 -n ai-fabric-be eda.nokia.com/tenant=gpucluster2