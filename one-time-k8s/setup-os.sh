#!/bin/bash

#Upgrade the kernel version on Ubuntu-16.04
sudo apt-get update -y
# https://blog.programster.org/ubuntu-16-04-upgrade-kernel
sudo apt-get install --install-recommends \
linux-generic-hwe-16.04 -y
sudo reboot

# Disable swap
sudo sed -i '/swap/s/^/#/g' /etc/fstab

# Install Docker
sudo apt-get update && apt-get -y install docker.io

sudo systemctl enable docker && systemctl start docker

# Install k8s pre-req
sudo apt-get update && sudo apt-get install -y apt-transport-https

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update && sudo apt-get install -y kubelet=1.10.* kubeadm=1.10.* kubectl

# SRIOV interfaces in MCORD machines: ens802f0, ens802f1. We are using only one interface per machine for MWC demo
# to bring it up: 
ifconfig ens802f0 up
# To check the interface bandwidth: ethtool ens802f0


## Performance setup

#Configure hugepages (customize, here 32G) and IOMMU. Make sure BIOS has `VT-d` enabled
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/c\GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on default_hugepagesz=1G hugepagesz=1G hugepages=32"' /etc/default/grub
update-grub

#Mount hugepages on boot
echo 'nodev /dev/hugepages hugetlbfs pagesize=1GB 0 0' | tee -a /etc/fstab

#Install lastest i40e driver (and firmware, if necessary. Not described here)
apt-get install -y make gcc

I40E_VER=2.4.10
wget https://downloadmirror.intel.com/24411/eng/i40e-${I40E_VER}.tar.gz && \
tar xvzf i40e-${I40E_VER}.tar.gz && cd i40e-${I40E_VER}/src && make install && cd -

#Setup vfio-pci module to load on boot, dpdk and sriov script
echo 'vfio-pci' | tee /etc/modules-load.d/vfio-pci.conf
wget -qO- https://fast.dpdk.org/rel/dpdk-17.11.2.tar.xz | tar -xJC /opt
mv /opt/dpdk-* /opt/dpdk

mkdir -p /sriov-cni /opt/scripts
cat << "EOF" > /opt/scripts/sriov.sh
#!/bin/bash
# Copied from infra/sriov.sh
# Usage: ./sriov.sh ens785f0

NUM_VFS=$(cat /sys/class/net/$1/device/sriov_totalvfs)
echo 0 | tee /sys/class/net/$1/device/sriov_numvfs
echo $NUM_VFS | tee /sys/class/net/$1/device/sriov_numvfs
sudo ip link set $1 up
for ((i = 0 ; i < ${NUM_VFS} ; i++ )); do sudo ip link set $1 vf $i spoofchk off; done
#for ((i = 0 ; i < ${NUM_VFS} ; i++ )); do sudo ip link set dev $1 vf $i state enable; done
EOF

# Script perms
sudo chmod 744 /opt/scripts/sriov.sh

#Setup SRIOV on `ens802f0` for `sriov-cni` to use
# Systemd unit to run the above script
cat << "EOF" > /etc/systemd/system/sriov.service
[Unit]
Description=Create VFs for ens802f0

[Service]
Type=oneshot
ExecStart=/opt/scripts/sriov.sh ens802f0

[Install]
WantedBy=default.target
EOF

# Enable the SRIOV systemd unit
systemctl enable sriov
```

## Convenience setup

# #Configure mgmt interface to come up on boot with dhcp
# cat > /etc/systemd/network/dhcp.network << "EOF"
# [Match]
# Name=eno*

# [Network]
# DHCP=yes
# EOF

# systemctl enable systemd-networkd


# #Configure perms of `stack` user, home and groups (customize for your user)
# MYUSER=stack
# chown -R $MYUSER:$MYUSER /home/$MYUSER
# usermod -aG docker $MYUSER

# sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers
# echo "$MYUSER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99_$MYUSER
# chmod 440 /etc/sudoers.d/99_$MYUSER
