# Kubernetes Network Plugin Setup

Kubernetes requires a Container Network Interface (CNI) plugin to enable pod-to-pod networking. This guide covers installing popular network plugins on Ubuntu clusters.

---

## Prerequisites

* A Kubernetes cluster initialized with `kubeadm`
* `kubectl` configured for cluster access
* Nodes in `Ready` status
* Sudo privileges

---

## 1. Calico (Recommended)

Calico provides network policy enforcement and scalable networking.

```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

**Verify installation:**

```bash
watch kubectl get pods -n kube-system ```

Wait until all pods show `Running` or `Completed`.

**Documentation:** [Calico for Kubernetes](https://docs.projectcalico.org/getting-started/kubernetes/)

---

## 2. Flannel (Lightweight Alternative)

Flannel is simple and lightweight, ideal for small clusters or practice environments.

```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

**Verify installation:**

```bash
kubectl get pods -n kube-system
```

**Documentation:** [Flannel GitHub](https://github.com/flannel-io/flannel)

---

## 3. Weave Net

Weave Net provides a simple overlay network with encryption support.

```bash
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

**Verify installation:**

```bash
kubectl get pods -n kube-system
```

**Documentation:** [Weave Net](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/)

---

## 4. Verification

After installing your chosen CNI plugin:

1. Check that all system pods are running:

```bash
kubectl get pods -n kube-system
```

2. Test pod-to-pod connectivity:

```bash
kubectl run test-pod --image=busybox --restart=Never -- sleep 3600
kubectl exec -it test-pod -- ping <another-pod-IP>
```

---

✅ At this point, your base system is ready for adding a worker node to the cluster installation.
* [Adding Worker Node to the Cluster](06-join-node.md)

## References

* [Kubernetes CNI Overview](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
* [Calico CNI](https://docs.projectcalico.org/getting-started/kubernetes/)
* [Flannel CNI](https://github.com/flannel-io/flannel)
* [Weave Net CNI](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/)

---
