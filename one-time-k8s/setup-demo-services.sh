#!/bin/bash

kubectl create namespace demo-services
kubectl label namespace demo-services istio-injection=enabled

#Install the demo services
#Prerequisites:
# - CD into mwc-americas-2018/one-time-k8s directory
kubectl create -f download-service.yaml
kubectl create -f streaming-service.yaml
