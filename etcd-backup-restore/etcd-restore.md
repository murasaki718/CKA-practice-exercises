
## etcd Restore (Kubernetes)

This guide explains how to **restore your Kubernetes etcd cluster** from a backup snapshot.

---

## 1. Pre-Requisites

* Access to **control plane node** (`cp1`).
* Snapshot file available (e.g., `/tmp/etcd-backup-2025-08-23_21:00.db`).

---

## 2. Stop kubelet

```bash
sudo systemctl stop kubelet
```

---

## 3. Move Old Data Directory

```bash
sudo mv /var/lib/etcd /var/lib/etcd-old-$(date +%F_%T)
sudo mkdir -p /var/lib/etcd
```

---

## 4. Restore Snapshot

```bash
sudo ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup-*.db \
  --data-dir /var/lib/etcd \
  --initial-cluster cp1=https://127.0.0.1:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-advertise-peer-urls https://127.0.0.1:2380
```

> Replace `cp1` and IPs if multiple control plane nodes exist.

---

## 5. Adjust etcd Static Pod Manifest

* Ensure the manifest points to the restored `data-dir`:

```bash
/etc/kubernetes/manifests/etcd.yaml
```

* Confirm `data-dir: /var/lib/etcd` is correct.

---

## 6. Start kubelet / etcd Pod

```bash
sudo systemctl start kubelet
kubectl get pods -n kube-system
kubectl logs -n kube-system etcd-cp1
```

* etcd pod should show `Running`.

---

## 7. Verify Cluster Health

```bash
kubectl get componentstatuses
ETCDCTL_API=3 etcdctl --endpoints=$ETCDCTL_ENDPOINTS endpoint health
```

* Ensure etcd endpoints report `healthy`.
* Kubernetes components should be functional.

---

## References

* [Kubeadm etcd restore](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#restore-etcd)
* [etcdctl documentation](https://etcd.io/docs/v3.5/dev-guide/interacting_v3/)

---

✅ Once restore is complete, verify workloads, nodes, and etcd health before resuming production operations.

---
