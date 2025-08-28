## Upgrade Control Plane Nodes (kubeadm)

This document describes how to upgrade the Kubernetes **control plane** using `kubeadm`. It assumes pre-upgrade checks have been completed (see `01-pre-upgrade-checks.md`).

---

## 1. Verify Current Versions

On the control plane node (`cp1`):

```bash
kubectl get nodes
kubectl get pods -n kube-system
kubectl version --short
kubeadm version
```

* Note the **current Kubernetes version** of the cluster and kubeadm.
* Confirm that the target upgrade version is compatible ([Version Skew Policy](https://kubernetes.io/docs/setup/release/version-skew-policy/)).

---

## 2. Upgrade kubeadm

### Add 1.33 repository

Update the package repository and upgrade kubeadm to the desired version:
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

```

Upgrade kubeadm to the desired version:
```bash
sudo apt-mark unhold kubeadm
sudo apt-get update && sudo apt-get install -y kubeadm=1.33.4-1.1
sudo apt-mark hold kubeadm
```

**Verify the version:**

```bash
kubeadm version
```

---

## 3. Plan the Upgrade

Run a dry-run plan to ensure compatibility:

```bash
sudo kubeadm upgrade plan
```

* Output shows available versions and recommended upgrades.
* Verify that all nodes and control plane components are compatible with the target version.

---

## 4. Upgrade Control Plane Components

Execute the upgrade on the first control plane node:

```bash
sudo kubeadm upgrade apply 1.33.4
```

* Confirm the upgrade when prompted.
* The command will upgrade **kube-apiserver, kube-controller-manager, kube-scheduler**, and update **etcd manifests** if applicable.

---

## 5. Upgrade kubelet and kubectl

On the same control plane node:

```bash
sudo apt-get install -y kubelet=1.33.4-00 kubectl=1.33.4-00
sudo apt-mark hold kubelet kubectl
```

* Restart kubelet to apply changes:

```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

---

## 6. Verify Control Plane Upgrade

Check node status:

```bash
kubectl get nodes
kubectl get pods -n kube-system
```

* Control plane node should be `Ready`.
* All `kube-system` pods should be running.

Check Kubernetes version:

```bash
kubectl version --short
```

---

## 7. Repeat for Additional Control Plane Nodes

If you have more than one control plane node:

1. Drain the node (optional for HA):

```bash
kubectl drain <node-name> --ignore-daemonsets
```

2. Upgrade kubeadm on that node.
3. Run:

```bash
sudo kubeadm upgrade node
```

4. Upgrade kubelet and kubectl as in step 5.
5. Uncordon the node:

```bash
kubectl uncordon <node-name>
```

---

## 8. Post-Upgrade Verification

* All control plane nodes are `Ready`.
* All system pods are running.
* CNI pods are functioning correctly.
* Ensure cluster-wide workloads are stable.

```bash
kubectl get nodes
kubectl get pods -A
kubectl get pods -n kube-system
```
---

✅ After upgrading all control plane nodes, the cluster is ready for **worker node upgrades**, described in `03-upgrade-worker-nodes.md`.
* [Worker Node Upgrade Pre-check](02-pre-upgrade-worker-nodes.md)
---

## References

* [Kubeadm Upgrade Docs](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
* [Kubernetes Version Skew Policy](https://kubernetes.io/docs/setup/release/version-skew-policy/)
* [Kubernetes Control Plane Components](https://kubernetes.io/docs/concepts/overview/components/)

