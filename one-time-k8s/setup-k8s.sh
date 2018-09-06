#SETUP

#Install k8s cluster using `kubeadm` this is on the first node
sudo kubeadm init --pod-network-cidr 10.244.0.0/16 --kubernetes-version stable-1.10

# On the master node, Copy credentials
rm -rf $HOME/.kube && mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# On the second and third node, join to the cluster. Run something like this. 
# Note the need for --ignore-preflight-errors=cri option:

#kubeadm join 10.90.0.215:6443 --token pcwnzg.79avu44oe3nr90a8 \
#--discovery-token-ca-cert-hash sha256:668f7a720a7cc7c3e913b31dddeb76f479ef6ac916a10d3728d2be60fdf24c60 \
#--ignore-preflight-errors=cri

#On the master node: Deploy CNI of choice, here `flannel` and wait for DNS to be ready
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml

while [[ ! $(kubectl get pods -n kube-system -l k8s-app=kube-dns | awk 'FNR == 2 {print $2}') = "3/3" ]];
do echo "Waiting for kube-dns"; sleep 2; done

#On the master node: Untaint the master node so you can schedule pods on them
kubectl taint nodes $(hostname) node-role.kubernetes.io/master:NoSchedule-

## Setup MCORD pre-reqs

#The daemonset expects a configmap with name `multus-conf` to exist in `kube-system` namespace
# Note: These files were modified by pingping for subnets. Use the files she modified

kubectl apply -f multus-conf.yaml
kubectl apply -f multus-sriov-dp.yaml

#Install a stand-alone etcd for use with `centralip` ipam plugin and deploy the additional networks
# Note: These files were modified by pingping for subnets. Use the files she modified

kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/kubernetes/addons/etcd/standalone-etcd.yaml
kubectl apply -f ngic-networks-hybrid.yaml


#RESET 
# Run the reset.sh script from the mcord directory provided by intel
# ./reset.sh
# Delete or move /etc/kubernetes directory
# systemctl stop kubelet.service
# systemctl disable kubelet.service
# rm /etc/systemd/system/kubelet.service
# rm -rf /etc/systemd/system/kubelet.service.d
# systemctl daemon-reload
# systemctl reset-failed


# systemctl stop etcd.service
# systemctl disable etcd.service
# rm /etc/systemd/system/etcd.service
# rm -rf /etc/systemd/system/etcd.service.d
# systemctl daemon-reload
# systemctl reset-failed

# Setup with Kubespray - but this has problems right now:
# STEPS:
# - Make sure your SSH public key is on all the machines in the cluster
# - if your SSH key is behind a password, make sure you run ssh-add to avoid entering password everytime
# - Pull the CORD source
# - CD into <CORD-DIRECTORY>/automation-tools/kubespray-installer directory
# - Add the line `- 'kube_cadvisor_port: 4194'` to the task "Add lines to the all.yaml variable file" in the file k8s-configs.yaml

# ./setup.sh -i mcord 10.90.0.215 10.90.0.217 10.90.0.222