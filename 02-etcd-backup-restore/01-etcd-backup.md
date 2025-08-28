## etcd Backup (Kubernetes)

This guide covers how to **take a snapshot of your etcd cluster** to protect your Kubernetes data.

---

## 1. Pre-Requisites

* Access to **control plane node** (`cp1`).
* `etcdctl` installed (usually included with kubeadm).
* Proper environment variables set for etcd cluster access.

Validate the presence of etcdctl
```bash
which etcdctl
```

Download the etcd client, if not present
```bash
# Download etcd client
wget https://github.com/etcd-io/etcd/releases/download/v3.5.15/etcd-v3.5.15-linux-amd64.tar.gz
tar xzvf etcd-v3.5.15-linux-amd64.tar.gz
sudo mv etcd-v3.5.15-linux-amd64/etcdctl /usr/local/bin
sudo mv etcd-v3.5.15-linux-amd64/etcdutl /usr/local/bin
```
---

## 2a. Backup etcd

```bash
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key
export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379

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

## 2b. Backup etcd using the etcd Kubernetes container

### Check the version of your etcd cluster, which depends on how you installed it.

```bash
ETCD_POD_NAME=$(kubectl get po -A --no-headers -o custom-columns=":metadata.name" | grep etcd)
kubectl exec -it -n kube-system $ETCD_POD_NAME -- etcd --version
etcd Version: 3.5.15
Git SHA: 0452feec7
Go Version: go1.16.15
Go OS/Arch: linux/amd64
```

### Prepare and Perform etcd snapshot/backup
```bash
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key
export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379

sudo ETCDCTL_API=3 etcdctl \
  --endpoints=$ETCDCTL_ENDPOINTS \
  --cacert=$ETCDCTL_CACERT \
  --cert=$ETCDCTL_CERT \
  --key=$ETCDCTL_KEY \
  snapshot save /tmp/etcd-backup-$(date +%F_%T).db
```

---

## 3. Verify Backup

```bash
sudo ETCDCTL_API=3 etcdctl snapshot status /tmp/etcd-backup-*.db
```

#### OR ####

### View the snapshot
```bash
sudo etcdutl --write-out=table snapshot status /tmp/etcd-backup-*.db
```

```output
+---------+----------+------------+------------+
|  HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+---------+----------+------------+------------+
| 74116f1 |     2616 |       2639 |     4.5 MB |
+---------+----------+------------+------------+

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
✅ At this point, you're ready to restore the etcd snapshot/backup to the system.

* [Restoring etcd](02-etcd-restore.md)
---

## References

* [Kubeadm etcd backup](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backup-etcd)
* [etcdctl documentation](https://etcd.io/docs/v3.5/dev-guide/interacting_v3/)
