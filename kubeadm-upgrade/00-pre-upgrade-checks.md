## Pre-Upgrade Checks for Control Plane Node(s) (kubeadm)

Before upgrading the Kubernetes **control plane**, ensure cluster health, configuration, and backups are properly prepared. This guide is **control-plane-centric**; worker nodes are handled separately.

---

## 1. Verify Control Plane Node Status

Check the control plane node(s):

```bash
kubectl get nodes
kubectl get pods -n kube-system
```

* Control plane nodes should be `Ready`.
* Core system pods (`kube-apiserver`, `kube-controller-manager`, `kube-scheduler`, `etcd`) must be running.

---

## 2. Check kubeadm Version

On the control plane node (`cp1`):

```bash
kubeadm version
```

* Note the current kubeadm version.
* Verify the **target upgrade version** is compatible ([Version Skew Policy](https://kubernetes.io/docs/setup/release/version-skew-policy/)).

---

## 3. Backup Critical Control Plane Data

### etcd Snapshot (self-hosted)

```bash
ETCDCTL_API=3 etcdctl snapshot save ~/etcd-snapshot-$(date +%F).db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

### Backup kubeadm Configuration

```bash
sudo cp -r /etc/kubernetes ~/kubernetes-backup-$(date +%F)
```

> For cloud-managed etcd, follow the provider-specific backup procedure.

---

## 4. Verify Control Plane Services

Check kubelet and container runtime:

```bash
sudo systemctl status kubelet
sudo systemctl status containerd
```

* Both services should be active and running.

---

## 5. Validate Network Plugin (CNI)

Ensure CNI pods are running:

```bash
kubectl get pods -n kube-system | grep calico
# Replace 'calico' with your CNI plugin if different
```

* Optional: Test network connectivity between pods if desired.

---

## 6. Plan kubeadm Upgrade

Check available kubeadm versions:

```bash
apt-cache policy kubeadm
```

* Choose a target version compatible with the cluster.
* Review Kubernetes changelog for any **control-plane-breaking changes**.

---

## References

* [Kubeadm Upgrade Docs](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
* [Kubernetes Version Skew Policy](https://kubernetes.io/docs/setup/release/version-skew-policy/)
* [Kubernetes Control Plane Components](https://kubernetes.io/docs/concepts/overview/components/)

---

✅ Once all pre-upgrade checks are complete and backups are confirmed, the control plane node is ready for the upgrade.

---