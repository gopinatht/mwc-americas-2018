#!/bin/bash

kubectl create namespaces epc1
kubectl create namespaces epc2
kubectl create namespaces epc3

#CD to mwc-americas-2018
# To create
./create-tosca.sh VEPCServiceInstance-mcord1.yaml
./create-tosca.sh VEPCServiceInstance-mcord2.yaml
./create-tosca.sh VEPCServiceInstance-mcord3.yaml

# To delete
./delete-tosca.sh VEPCServiceInstance-mcord1.yaml
./delete-tosca.sh VEPCServiceInstance-mcord2.yaml
./delete-tosca.sh VEPCServiceInstance-mcord3.yaml