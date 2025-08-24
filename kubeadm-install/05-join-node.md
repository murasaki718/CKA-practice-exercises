# Join Worker Nodes to Kubernetes Cluster (Containerd)

This document combines **worker node setup** and **joining** steps for Ubuntu nodes using containerd. It covers all preparation, prerequisites, and the join process for nodes `worker1` and `worker2` to the control plane `cp1`.

---

## 1. Prerequisites

Before joining the cluster, ensure the following are completed on **all worker nodes**:

* [System Configuration](01-system-requirements.md)

  * Base system setup: hostnames, swap disabled, kernel modules, sysctl parameters, and time sync.
* [Container Runtime Setup (containerd)](02-containerd.md)

  * containerd installed, configured, and running.
* [Kubernetes Tools Installation](03-install-kube-tools.md)

  * `kubeadm`, `kubectl`, `kubelet` installed and verified.

> Worker nodes must meet all requirements before proceeding. Packages like `apt-transport-https`, `ca-certificates`, and `curl` are already installed in previous steps.

---

## 2. Obtain Join Command from Control Plane (`cp1`)

On the control plane node `cp1`, run:

```bash
kubeadm token create --print-join-command
```

**Example output:**

```bash
sudo kubeadm join 192.168.1.100:6443 --token abcdef.0123456789abcdef \
  --discovery-token-ca-cert-hash sha256:1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

> Save this command — it will be used on each worker node.

---

## 3. Join Worker Nodes to Cluster

Run the join command on each worker node:

```bash
# On worker1
sudo kubeadm join 192.168.1.100:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef

# On worker2
sudo kubeadm join 192.168.1.100:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

> kubeadm automatically configures kubelet to use containerd; no Docker steps are required.

---

## 4. Verify Worker Nodes on Control Plane (`cp1`)

On `cp1`:

```bash
kubectl get nodes
```

Expected output:

```
NAME     STATUS   ROLES          AGE   VERSION
cp1      Ready    control-plane  30m   v1.32.8
worker1  Ready    <none>         5m    v1.32.8
worker2  Ready    <none>         5m    v1.32.8
```

* `STATUS` should show `Ready`.
* If `NotReady`, check services on the worker nodes:

```bash
sudo systemctl status kubelet
sudo systemctl status containerd
```

---

## 5. Troubleshooting

* **Token Expired:** Generate a new token on `cp1`:

```bash
kubeadm token create
```

* **CA Cert Hash Mismatch:** Retrieve hash from `cp1`:

```bash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | \
  openssl rsa -pubin -outform der 2>/dev/null | \
  openssl dgst -sha256 -hex | sed 's/^.* //'
```

* **CNI Network Issues:** Verify pods in kube-system namespace:

```bash
kubectl get pods -n kube-system
```

---

## References

* [System Configuration](system-requirements.md)
* [Container Runtime Setup (containerd)](containerd.md)
* [Install Kubernetes Tools](install-kube-tools.md)
* [Kubeadm Worker Node Join](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/)
* [Kubernetes Nodes Overview](https://kubernetes.io/docs/concepts/architecture/nodes/)

---
