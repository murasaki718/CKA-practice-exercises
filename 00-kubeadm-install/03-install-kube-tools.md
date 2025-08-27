# Install Kubernetes Tools on Ubuntu

This guide installs `kubectl`, `kubeadm`, `kubelet`, and sets up the system for Kubernetes cluster creation.

---

## Prerequisites

* Ubuntu 22.0
* Sudo privileges
* Internet connectivity

---
## 1. Add Kubernetes Repository

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
```

---

## 2. Install Kubernetes Tools

```bash
sudo apt-get install -y kubelet=1.32.8-1.1 kubeadm=1.32.8-1.1 kubectl=1.32.8-1.1

sudo apt-mark hold kubelet kubeadm kubectl
```

**Verify versions:**

```bash
kubectl version --client
kubeadm version
kubelet --version
```

---

✅ At this point, your base system is ready to initialize cluster installation.
* [Init Cluster](04-int-cluster.md)

---
## References

* [Installing-kubetools - kubeadm-kubelet-and-kubectl](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)
* [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
* [Setup Tools - kubeadm init](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/)
---
