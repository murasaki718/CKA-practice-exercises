#!/bin/bash

# initial system update and upgrade
sudo apt-get update && apt-get upgrade

cat <<EOF > machines.txt
10.0.1.175 k8s-controller.kubernetes.local k8s-controller
10.0.1.207 k8s-node1.kubernetes.local k8s-node1 10.200.0.0/24
10.0.1.210 k8s-node2.kubernetes.local k8s-node2 10.200.1.0/24
EOF

# set dns hosts file
echo "" > hosts
echo "# Kubernetes The Hard Way" >> hosts

while read IP FQDN HOST SUBNET; do 
    ENTRY="${IP} ${FQDN} ${HOST} ${SUBNET}"
    echo "$ENTRY" >> hosts
done < machines.txt

sudo cat hosts | sudo tee -a /etc/hosts

# disabled swap file
swapoff -a

# make changes in /etc/fstab to persist disabling of Swap on reboot
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# containerd preinstall configuration
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Install containerd 
## Set up the repository
### Install packages to allow apt to use a repository over HTTPS
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

## Install packages
sudo apt-get install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd

# Install Kubeadm
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet=1.30.5-1.1 kubeadm=1.30.5-1.1 kubectl=1.30.5-1.1
sudo apt-mark hold kubelet kubeadm kubectl
