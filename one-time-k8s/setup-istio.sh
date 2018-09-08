# Do this after kubernetes is installed

curl -L https://git.io/getLatestIstio | sh -

# CD into istio directory
cd istio-1.0.2
export PATH=$PWD/bin:$PATH

kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
kubectl apply -f install/kubernetes/istio-demo.yaml

#Wait a couple of minutes
sleep 2m