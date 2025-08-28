## Upgrade Worker Nodes (kubeadm)

This guide describes how to upgrade **worker nodes** after the control plane has been upgraded. Ensure **pre-upgrade checks** (`02-pre-upgrade-worker-nodes.md`) are complete before proceeding.

---

## 1. Verify Worker Node Status

Check the current state of all worker nodes:

```bash
kubectl get nodes
kubectl get pods -n kube-system
```

* Worker nodes should show `Ready`.
* All CNI pods (Calico, Flannel, etc.) must be running.

> Resolve any issues before upgrading.

---

## 2. Drain the Worker Node (Optional but Recommended)

To avoid disrupting workloads:

```bash
kubectl drain <worker-node-name> --ignore-daemonsets --delete-local-data
```

* `--ignore-daemonsets` keeps CNI pods running.
* `--delete-local-data` removes pods using local storage.

---

## 3. Add Kubernetes Repository & Upgrade kubeadm

Set up the repository for **v1.33**:

```bash
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
```

Upgrade kubeadm:

```bash
sudo apt-get install -y kubeadm=1.33.4-00
sudo apt-mark hold kubeadm
kubeadm version
```

---

## 4. Upgrade the Node

Run the kubeadm upgrade command on the worker node:

```bash
sudo kubeadm upgrade node
```

* Ensures kubelet manifests are compatible with the upgraded control plane.

---

## 5. Upgrade kubelet and kubectl

```bash
sudo apt-get install -y kubelet=1.33.4-00 kubectl=1.33.4-00
sudo apt-mark hold kubelet kubectl

sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

---

## 6. Uncordon the Worker Node

Bring the node back into the cluster scheduling pool:

```bash
kubectl uncordon <worker-node-name>
```

* Node status should return to `Ready`.
* Workloads will start running on this node again.

---

## 7. Repeat for All Worker Nodes

Perform the steps **one worker node at a time** to maintain cluster stability.

---

## 8. Post-Upgrade Verification

Check all nodes and pods:

```bash
kubectl get nodes
kubectl get pods -n kube-system
kubectl get pods -A
```

* All worker nodes should be `Ready`.
* CNI pods and workloads should function normally.


```
kubectl get nodes
NAME               STATUS                     ROLES           AGE   VERSION
cp1                Ready                      control-plane   15m   v1.33.4
worker1            Ready,SchedulingDisabled   <none>          13m   v1.33.4
worker2            Ready,SchedulingDisabled   <none>          13m   v1.33.4
```

Optional test:

```bash
kubectl run test-pod --image=busybox --restart=Never -- sleep 3600
kubectl exec -it test-pod -- ping <another-pod-ip>
kubectl delete pod test-pod
```
---

✅ Once all worker nodes are upgraded and verified, the cluster is fully upgraded and ready for production workloads.

---

## References

* [Kubeadm Upgrade Docs](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
* [Kubernetes Version Skew Policy](https://kubernetes.io/docs/setup/release/version-skew-policy/)
* [Kubernetes Nodes Overview](https://kubernetes.io/docs/concepts/architecture/nodes/)
