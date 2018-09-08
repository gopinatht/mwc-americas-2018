#!/bin/bash

#sudo mkdir -p /home/cord/nginx-content
#sudo chmod 777 /home/cord
#sudo chmod 777 /home/cord/nginx-content
#cd /home/cord/nginx-content
#fallocate -l 10G mwcdownload.bin
#

kubectl create namespace demo-services
kubectl label namespace demo-services istio-injection=enabled

#Install the demo services
#Prerequisites:
# - CD into mwc-americas-2018/one-time-k8s directory
kubectl create -f download-service.yaml
kubectl create -f download-deployment-v1.yaml
kubectl create -f download-gateway.yaml
kubectl create -f demodownload-route-v1.yaml

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o 'jsonpath={.items[0].status.hostIP}')

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

kubectl create -f download-destination-rule.yaml

kubectl create -f streaming-service.yaml
