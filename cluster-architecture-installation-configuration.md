# Cluster Architecture, Installation & Configuration (25%)

## Manage role-based access control (RBAC)

Doc: https://kubernetes.io/docs/reference/access-authn-authz/rbac/

## Use kubeadm to install a basic cluster

<details><summary>Solution</summary>
<p>

If you don't have cluster nodes yet, check the terraform deployment from below: [Provision underlying infrastructure to deploy a Kubernetes cluster](https://github.com/murasaki718/CKA-practice-exercises/blob/CKA-v1.31/cluster-architecture-installation-configuration.md#provision-underlying-infrastructure-to-deploy-a-kubernetes-cluster)

Installation from [scratch using Kelsey Hightower's kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way/) is too time-consuming but not irrelevant. We will be using kubeadm (v1.30.5) to install the Kubernetes cluster.

### Install containerd runtime

<details><summary>Solution</summary>
<p>

Doc: https://kubernetes.io/docs/setup/production-environment/container-runtimes/

We will do this using only three nodes (here is the path to the script https://github.com/murasaki718/CKA-practice-exercises/blob/CKA-v1.31/containerd-install.sh):

```bash
# containerd preinstall configuration
# initial system update and upgrade
apt-get update && apt-get upgrade

# disabled swap file
swapoff -a

# make changes in /etc/fstab to persist disabling of Swap on reboot
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


# Load required Kernel Modules
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Install containerd
## Set up the repository
### Install packages to allow apt to use a repository over HTTPS
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

## Install packages
sudo apt-get update
sudo apt-get install -y containerd

# Configure containerd defaults
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null 2>&1
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd.service
sudo systemctl restart containerd.service
```

</p>
</details>

### Install kubeadm, kubelet and kubectl

<details><summary>Solution</summary>
<p>

Doc: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

Do this on all three-nodes:

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet=1.30.5-1.1 kubeadm=1.30.5-1.1 kubectl=1.30.5-1.1
sudo apt-mark hold kubelet kubeadm kubectl
```

</p>
</details>

### Create a cluster with kubeadm

<details><summary>Solution</summary>
<p>

Doc: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

Make sure the nodes have different hostnames.

On control-plane node:
```bash
sudo kubeadm init --kubernetes-version=1.30.5 --pod-network-cidr=10.244.0.0/16
```

Run the output of the init command on the other nodes:
```bash
sudo kubeadm join 192.168.254.11:6443 --token h8vno9.7eroqaei7v1isdpn \
    --discovery-token-ca-cert-hash sha256:44f1def2a041f116bc024f7e57cdc0cdcc8d8f36f0b942bdd27c7f864f645407
```

On control-plane node again:
```bash
# Configure kubectl access
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deloying Kubernetes Cluster Network Plugin using Either 

## Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml

## Flannel
#kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

</p>
</details>

### Check that your nodes are running and ready

<details><summary>Solution</summary>
<p>

```bash
kubectl get nodes
NAME               STATUS   ROLES           AGE     VERSION
k8s-controller      Ready    control-plane   3m29s   v1.30.5
k8s-node-1          Ready    <none>          114s    v1.30.5
k8s-node-2          Ready    <none>          77s     v1.30.5
```

</p>
</details>

</p>
</details>

## Perform a version upgrade on a Kubernetes cluster using KubeADM

<details><summary>Solution</summary>
<p>

Doc: https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

After installing Kubernetes v1.31 here: [install](https://github.com/murasaki718/CKA-practice-exercises/blob/CKA-v1.31/cluster-architecture-installation-configuration.md#use-kubeadm-to-install-a-basic-cluster)

We will now upgrade the cluster to v1.31.

On control-plane node:

```bash
# Add 1.31 repository
sudo sh -c 'echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" >> /etc/apt/sources.list.d/kubernetes.list'

# Upgrade kubeadm
sudo apt-mark unhold kubeadm
sudo apt-get update && sudo apt-get install -y kubeadm=1.31.1-1.1
sudo apt-mark hold kubeadm

# Upgrade control-plane node
kubectl drain k8s-controller --ignore-daemonsets
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.31.1

# Update Network Plugin

## Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/calico.yaml

## Flannel
#kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get update && sudo apt-get install -y kubelet=1.31.1-1.1 kubectl=1.31.1-1.1
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Make control-plane node reschedulable
kubectl uncordon k8s-controller
```

On worker nodes:

```bash
# Add 1.31 repository
sudo sh -c 'echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" >> /etc/apt/sources.list.d/kubernetes.list'

# Upgrade kubeadm
sudo apt-mark unhold kubeadm
sudo apt-get update && sudo apt-get install -y kubeadm=1.31.1-1.1
sudo apt-mark hold kubeadm

# Upgrade the other node
kubectl drain k8s-node-1 --ignore-daemonsets
sudo kubeadm upgrade node

# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get update && sudo apt-get install -y kubelet=1.31.1-1.1 kubectl=1.31.1-1.1
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Make worker node reschedulable
kubectl uncordon k8s-node-1
```

Verify that the nodes are upgraded to v1.31.1:

```bash
kubectl get nodes
NAME               STATUS                     ROLES           AGE   VERSION
k8s-controller     Ready                      control-plane   15m   v1.31.1
k8s-node-1         Ready,SchedulingDisabled   <none>          13m   v1.31.1
k8s-node-2         Ready,SchedulingDisabled   <none>          13m   v1.31.1
```

</p>
</details>

### Facilitate operating system upgrades

<details><summary>Solution</summary>
<p>

When we only have one control plane node in your cluster, you cannot upgrade the OS system (with reboot) without losing temporary access to your cluster.

Here we will upgrade our worker nodes:

```bash
# Hold Kubernetes from upgrading
sudo apt-mark hold kubeadm kubelet kubectl

# Upgrade node
kubectl drain k8s-node-1 --ignore-daemonsets
sudo apt update && sudo apt upgrade -y # Be careful about container runtime (e.g., docker) upgrade.

# Reboot node if necessary
sudo reboot

# Make worker node reschedulable
kubectl uncordon k8s-node-1
```

</p>
</details>

## Provision underlying infrastructure to deploy a Kubernetes cluster

<details><summary>Solution</summary>
<p>

You can use any cloud provider (AWS, Azure, GCP, OpenStack, etc.) and multiple tools to provision nodes for your Kubernetes cluster.

We will deploy a three-node cluster, with one control plane node and two worker nodes.

Three Libvirt/KVM nodes (or any cloud provider you are using):
- k8s-controller: 2 vCPUs, 4GB RAM, 20GB Disk, 192.168.254.11/24
- k8s-node-1:        2 vCPUs, 2GB RAM, 20GB Disk, 192.168.254.21/24
- k8s-node-2:        2 vCPUs, 2GB RAM, 20GB Disk, 192.168.254.22/24

OS description:

```bash
$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 22.04.3 LTS
Release:	22.04
Codename:	jammy
```

We will use a local libvirt/KVM baremetal node with terraform (v1.2.5) to provision the three-node cluster described above.

```bash
mkdir terraform
cd terraform
wget https://raw.githubusercontent.com/murasaki718/CKA-practice-exercises/CKA-v1.31/terraform/cluster-infra.tf
terraform init
terraform plan
terraform apply
```

</p>
</details>

## Implement etcd backup and restore

<details><summary>Solution</summary>
<p>

### Backup etcd cluster

<details><summary>Solution</summary>
<p>

Doc: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster

Check the version of your etcd cluster, which depends on how you installed it.

```bash
ETCD_POD_NAME=$(kubectl get po -A --no-headers -o custom-columns=":metadata.name" | grep etcd)
kubectl exec -it -n kube-system $ETCD_POD_NAME -- etcd --version
etcd Version: 3.5.15
Git SHA: 0452feec7
Go Version: go1.16.15
Go OS/Arch: linux/amd64
```

If using connecting to an external etcd instance, Download the etcd client 
```bash
# Download etcd client
wget https://github.com/etcd-io/etcd/releases/download/v3.5.15/etcd-v3.5.15-linux-amd64.tar.gz
tar xzvf etcd-v3.5.15-linux-amd64.tar.gz
sudo mv etcd-v3.5.15-linux-amd64/etcdctl /usr/local/bin
sudo mv etcd-v3.5.15-linux-amd64/etcdutl /usr/local/bin
```

You are going to need the file locations first of the trusted-ca-file, cert-file, and key-file
```bash
# review the yaml spec.container command and extract the required information
kubectl get po $(echo $ETCD_CONTAINER) -n kube-system -o "jsonpath="{.spec.containers}"" | jq ".[].command"

CACERT="/run/config/pki/etcd/ca.crt"
CERT="/run/config/pki/etcd/server.crt"
KEY="/run/config/pki/etcd/server.key"
```

```bash
# save etcd snapshot
ETCDCTL_API=3 etcdctl --endpoints https://127.0.0.1:2379 --cacert=$(echo $CACERT) --cert=$(echo $CERT) --key=$(echo $KEY) snapshot save snapshot.db

# View the snapshot
sudo etcdutl --write-out=table snapshot status snapshot.db 
+---------+----------+------------+------------+
|  HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+---------+----------+------------+------------+
| 74116f1 |     2616 |       2639 |     4.5 MB |
+---------+----------+------------+------------+

#if etcdutl is unavailable
etcdctl --write-out=table snapshot status snapshot.db
Deprecated: Use `etcdutl snapshot status` instead.

+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| cbf239e9 |    35895 |        946 |     1.8 MB |
+----------+----------+------------+------------+

```

</p>
</details>

### Restore an etcd cluster from a snapshot

<details><summary>Solution</summary>
<p>

Doc: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster

Retrieve the Data dir location
```bash
kubectl get po $(echo $ETCD_CONTAINER) -n kube-system -o "jsonpath="{.spec.containers}"" | jq ".[].command" | grep "data-dir"

DATADIR="/var/lib/etcd"
```
Restore etcd from database snapshot/backup
```bash
# We are going to have to create a new directory to restore the contents of the backup
etcdutl --data-dir /var/lib/etcd-backup snapshot restore snapshot.db

# If we restore to the existing directory we will be presented with an ERROR message
etcdutl --data-dir /var/lib/etcd snapshot restore snapshot.db

#Deprecated: Use `etcdutl snapshot restore` instead.
#Error: data-dir "/var/lib/etcd/" not empty or could not be read

# If etcdutl is not available use the following command in place
ETCDCTL_API=3 etcdctl --endpoints https://127.0.0.1:2379 --cacert=$(echo $CACERT) --cert=$(echo $CERT) --key=$(echo $KEY) --data-dir=/var/lib/etcd-backup snapshot restore snapshot.db
Deprecated: Use `etcdutl snapshot restore` instead.

2024-10-30T03:16:06Z    info    snapshot/v3_snapshot.go:260     restoring snapshot      {"path": "snapshot.db", "wal-dir": "/var/lib/etcd-backup/member/wal", "data-dir": "/var/lib/etcd-backup", "snap-dir": "/var/lib/etcd-backup/member/snap"}
2024-10-30T03:16:06Z    info    membership/store.go:141 Trimming membership information from the backend...
2024-10-30T03:16:06Z    info    membership/cluster.go:421       added member    {"cluster-id": "cdf818194e3a8c32", "local-member-id": "0", "added-peer-id": "8e9e05c52164694d", "added-peer-peer-urls": ["http://localhost:2380"]}
2024-10-30T03:16:06Z    info    snapshot/v3_snapshot.go:287     restored snapshot       {"path": "snapshot.db", "wal-dir": "/var/lib/etcd-backup/member/wal", "data-dir": "/var/lib/etcd-backup", "snap-dir": "/var/lib/etcd-backup/member/snap"}
```

Updating the etcd yaml 
```bash
#TBD
```

</p>
</details>

</p>
</details>
