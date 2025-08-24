# System Configuration

This document covers the **base system setup** required on all Kubernetes nodes (control plane and workers). These steps ensure consistency, security, and compatibility with kubeadm and Kubernetes components.

---

## 1. Update System Packages

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Set Hostname

Set a unique, descriptive hostname for each node:

```bash
# Example: control plane
sudo hostnamectl set-hostname k8s-control-1

# Example: worker node
sudo hostnamectl set-hostname k8s-worker-1
```

Add entries to `/etc/hosts` for all cluster nodes:

```bash
192.168.1.10   k8s-control-1
192.168.1.11   k8s-worker-1
192.168.1.12   k8s-worker-2
```

---

## 3. Disable Swap

Kubernetes requires swap to be disabled:

```bash
sudo swapoff -a
```

Make it permanent by commenting out swap in `/etc/fstab`:

```bash
sudo sed -i.bak '/\/swap/s/^/#/' /etc/fstab
```

---

## 4. Configure Kernel Modules

Enable required modules:

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

---

## 5. Set Sysctl Parameters

Configure networking settings for Kubernetes:

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params
sudo sysctl --system
```

---

## 6. Time Synchronization

Ensure NTP is enabled for clock sync:

```bash
sudo apt install -y chrony
sudo systemctl enable --now chronyd
```

---

✅ At this point, your base system is ready for container runtime installation.

---

