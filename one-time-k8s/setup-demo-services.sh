#!/bin/bash

# Some house keeping commands
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
kubectl apply -f download-service.yaml
kubectl apply -f download-deployment-v1.yaml
kubectl apply -f download-gateway.yaml
kubectl apply -f demodownload-route-v1.yaml

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o 'jsonpath={.items[0].status.hostIP}')

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

kubectl apply -f download-destination-rule.yaml

kubectl apply -f streaming-service.yaml

#TESTING Commands
#kubectl run my-shell --rm -i --tty --image ubuntu -- bash
#kubectl exec <ubuntu pod>
#apt-get update
#apt-get install wget
#wget -c -t 0 --timeout=10 --waitretry=10 http://${GATEWAY_URL}/mwcdownload.bin
#wget -c -t 0 --timeout=10 --waitretry=10 http://nginx.demo-services.svc.cluster.local/mwcdownload.bin

#kubectl apply -f demodownload-route-v2.yaml && kubectl apply -f download-deployment-v2.yaml && kubectl delete -f download-deployment-v1.yaml

#kubectl apply -f demodownload-route-v1.yaml && kubectl apply -f download-deployment-v1.yaml && kubectl delete -f download-deployment-v2.yaml