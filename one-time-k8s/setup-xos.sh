#!/bin/bash

#Prerequisites:
# - Run this after Kubernetes is installed
# - CD into helm-charts directory
helm dep update xos-core
helm install xos-core -n xos-core

# Wait for 3 mts for all the XOS containers to come up and jobs to complete
sleep 3m

helm dep update xos-profiles/base-kubernetes
helm install xos-profiles/base-kubernetes -n base-kubernetes

# Wait for 2 mts for all the K8S synchronizer containers to come up and jobs to complete
sleep 2m