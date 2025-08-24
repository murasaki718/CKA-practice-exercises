## etcd Backup (Kubernetes)

This guide covers how to **take a snapshot of your etcd cluster** to protect your Kubernetes data.

---

## 1. Pre-Requisites

* Access to **control plane node** (`cp1`).
* `etcdctl` installed (usually included with kubeadm).
* Proper environment variables set for etcd cluster access.

```bash
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key
export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379
```

---

## 2. Backup etcd

```bash
sudo ETCDCTL_API=3 etcdctl \
  --endpoints=$ETCDCTL_ENDPOINTS \
  --cacert=$ETCDCTL_CACERT \
  --cert=$ETCDCTL_CERT \
  --key=$ETCDCTL_KEY \
  snapshot save /tmp/etcd-backup-$(date +%F_%T).db
```

* Copy snapshot to safe external storage:

```bash
scp /tmp/etcd-backup-*.db user@backup-server:/path/to/backups/
```

---

## 3. Verify Backup

```bash
sudo ETCDCTL_API=3 etcdctl snapshot status /tmp/etcd-backup-*.db
```

* Ensures snapshot is valid and readable.

---

## 4. Optional: Scheduled Backup (Cron Job)

```bash
0 2 * * * root ETCDCTL_API=3 /usr/local/bin/etcdctl \
  --endpoints=$ETCDCTL_ENDPOINTS \
  --cacert=$ETCDCTL_CACERT \
  --cert=$ETCDCTL_CERT \
  --key=$ETCDCTL_KEY \
  snapshot save /var/backups/etcd/etcd-snapshot-$(date +\%F).db
```

---

## References

* [Kubeadm etcd backup](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backup-etcd)
* [etcdctl documentation](https://etcd.io/docs/v3.5/dev-guide/interacting_v3/)

---
