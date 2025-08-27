# Initialize Kubernetes Cluster

This guide covers setting up a basic Kubernetes cluster with `kubeadm` on Ubuntu, including control-plane initialization and joining worker nodes.

---

## Prerequisites

* Ubuntu nodes (Master + Workers)
* `kubeadm`, `kubelet`, and `kubectl` installed
* Container runtime installed (Docker or containerd)
* Sudo privileges

---

## 1. Initialize Control Plane

On the master node, run:

```bash
sudo kubeadm init --kubernetes-version=1.32.8 --pod-network-cidr=10.244.0.0/16
```

**Notes:**

* `--pod-network-cidr` depends on the CNI plugin you plan to install (Flannel, Calico, etc.).
* This command outputs a **join command** for worker nodes.

---

## 2. Configure kubectl for Your User

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes
```

---

## 3. Install a Pod Network Add-on

### Example: Calico

```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

**Verify network installation:**

```bash
kubectl get pods -n kube-system
```

Wait until all pods show `Running` or `Completed`.

---

## 4. Join Worker Nodes

On each worker node, use the join command provided by `kubeadm init`:

```bash
sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
```

**Verify cluster nodes on master:**

```bash
kubectl get nodes
```

You should see all worker nodes in `Ready` status.

---

## 5. Optional: Enable Bash Completion

```bash
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

---

✅ At this point, your base system is ready to join worker nodes to the cluster installation.
* [Join Worker Node to the Cluster](05-join-node.md)
  
## References

* [Kubeadm Cluster Initialization](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
* [Kubernetes Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)

---
