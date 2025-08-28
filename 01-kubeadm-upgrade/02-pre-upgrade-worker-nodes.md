## Pre-Upgrade Checks for Worker Nodes (kubeadm)

Before upgrading worker nodes in a Kubernetes cluster, ensure the nodes are ready, workloads are safe, and the network is functional. This guide is **worker-node-centric**; control plane checks are handled separately.

---

## 1. Verify Worker Node Status

Check the status of all worker nodes:

```bash
kubectl get nodes
kubectl get pods -n kube-system
```

* Worker nodes should show `Ready`.
* All CNI pods (Calico, Flannel, etc.) must be running.
* No critical workloads should be crashing.

---

## 2. Verify kubelet and Container Runtime

On each worker node:

```bash
sudo systemctl status kubelet
sudo systemctl status containerd
```

* Both services should be active and running.
* Ensure container runtime (containerd) matches the version used by the cluster.

---

## 3. Validate Network Functionality

Check CNI pods on worker nodes:

```bash
kubectl get pods -n kube-system | grep calico
# Replace 'calico' with your CNI plugin if different
```

* Optional: Test pod-to-pod connectivity:

```bash
kubectl run test-pod --image=busybox --restart=Never -- sleep 3600
kubectl exec -it test-pod -- ping <another-pod-ip>
kubectl delete pod test-pod
```

---

## 4. Check kubeadm Version

On each worker node:

```bash
kubeadm version
```

* Record the current kubeadm version.
* Ensure the target upgrade version is compatible with the cluster control plane.

---

## 5. Optional: Drain Worker Node for Safe Upgrade

If performing a rolling upgrade, drain the node:

```bash
kubectl drain <worker-node-name> --ignore-daemonsets --delete-local-data
```

* `--ignore-daemonsets` ensures CNI and other DaemonSet pods remain.
* `--delete-local-data` removes pods using local storage to prevent conflicts.

---

## 6. Plan kubeadm Upgrade

Check available kubeadm versions:

```bash
apt-cache policy kubeadm
```

* Determine the target version compatible with the upgraded control plane.
* Confirm that all worker nodes can safely upgrade without version skew issues.

---
✅ After completing these pre-upgrade checks, worker nodes are ready for kubeadm, kubelet, and kubectl upgrades, described in 03-upgrade-worker-nodes.md.

* [Upgrade Worker Nodes](03-upgrade-worker-nodes.md)
---
## References

* [Kubeadm Upgrade Docs](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
* [Kubernetes Version Skew Policy](https://kubernetes.io/docs/setup/release/version-skew-policy/)
* [Kubernetes Nodes Overview](https://kubernetes.io/docs/concepts/architecture/nodes/)
