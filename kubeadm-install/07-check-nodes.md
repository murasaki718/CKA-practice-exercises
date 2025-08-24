# Verify Kubernetes Nodes

This guide explains how to check the status and health of nodes in your Kubernetes cluster using `kubectl`.

---

## 1. List All Nodes

```bash
kubectl get nodes
```

**Output Example:**

```
NAME        STATUS   ROLES    AGE   VERSION
master      Ready    master   10m   v1.32.8
worker1     Ready    <none>   5m    v1.32.8
worker2     Ready    <none>   5m    v1.32.8
```

**Key Fields:**

* **NAME:** Node hostname
* **STATUS:** `Ready`, `NotReady`, `SchedulingDisabled`
* **ROLES:** Master/control-plane or worker roles
* **VERSION:** Kubernetes version

---

## 2. Get Detailed Node Information

```bash
kubectl describe node <node-name>
```

**Provides:**

* Node conditions (Ready, MemoryPressure, DiskPressure, PIDPressure)
* Labels and taints
* Allocated resources (CPU, memory)
* Pod capacity and usage

---

## 3. Check Node Status Continuously

```bash
kubectl get nodes -w
```

* The `-w` flag watches for changes in real-time.

---

## 4. Verify Node Networking

* Ensure kubelet and CNI plugins are functioning.
* List pods on a node:

```bash
kubectl get pods --all-namespaces -o wide | grep <node-name>
```

* Ping between pods on different nodes to check connectivity:

```bash
kubectl exec -it <pod-name> -- ping <another-pod-IP>
```

---

## 5. Common Troubleshooting

* **Node Not Ready:** Check kubelet and container runtime status:

```bash
sudo systemctl status kubelet
sudo systemctl status docker
```

* **CNI Issues:** Verify CNI plugin pods:

```bash
kubectl get pods -n kube-system
```

* **Resource Pressure:** Inspect node conditions:

```bash
kubectl describe node <node-name>
```

---

## References

* [Kubernetes Nodes Overview](https://kubernetes.io/docs/concepts/architecture/nodes/)
* [kubectl get nodes](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get)
* [kubectl describe node](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe)

---