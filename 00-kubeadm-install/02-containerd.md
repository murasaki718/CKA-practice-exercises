# Container Runtime Setup (containerd)

Kubernetes requires a container runtime to run Pods. We will use **containerd**, the CNCF-graduated, lightweight, and Kubernetes-recommended runtime.

---

## Step 1. Install Dependencies

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release
```

---

## Step 2. Install containerd

```bash
sudo apt-get install -y containerd
```

Verify installation:

```bash
containerd --version
```

---

## Step 3. Configure containerd

Generate the default config file:

```bash
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null 2>&1

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo sed -i 's|sandbox_image = "registry.k8s.io/pause:3.8"|sandbox_image = "registry.k8s.io/pause:3.10"|' /etc/containerd/config.toml
```

(Optional - Manually) 

Edit `/etc/containerd/config.toml` and make sure the **CRI plugin** is enabled and set to use **systemd cgroups** (required for kubelet compatibility):

```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  SystemdCgroup = true
```

```toml
  [plugins."io.containerd.grpc.v1.cri"]
    sandbox_image = "registry.k8s.io/pause:3.10"
```
---

## Step 4. Restart and Enable containerd

```bash
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl status containerd
```

---

✅ At this point, containerd is installed, configured, and ready for Kubernetes.
* [Install Kubernetes Tools](03-install-kube-tools.md)
---
