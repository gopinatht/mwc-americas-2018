# Note: Run this after XOS is installed

# Install the Progran ONOS App
#Prerequisites:
# - CD into mwc-americas-2018/one-time-k8s directory
kubectl apply -f progran-deployment.yaml
kubectl apply -f progran-service.yaml

# Install the progran XOS synchronizer
#Prerequisites:
# - Run this after XOS is installed
# - CD into helm-charts directory
helm install -n progran-synchronizer xos-services/progran/