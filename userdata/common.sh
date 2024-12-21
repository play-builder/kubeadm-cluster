#!/bin/bash
##############################################################################
# common.sh — All Nodes: Install containerd + kubeadm + kubelet + kubectl
# Based on: https://kubernetes.io/docs/setup/production-environment/
##############################################################################
set -euxo pipefail

exec > >(tee /var/log/kubeadm-bootstrap.log) 2>&1
echo "=== Bootstrap started at $(date) ==="

# 0. Basic setup
hostnamectl set-hostname "${NODE_HOSTNAME}"

# Disable swap (required by kubeadm)
swapoff -a
sed -i '/swap/d' /etc/fstab

# 1. Kernel modules & sysctl (required for container networking)
cat > /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# 2. Install containerd (CRI runtime)
apt-get update
apt-get install -y ca-certificates curl gnupg

# Add Docker official GPG key & repository (for containerd package)
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y containerd.io=2.0.0-1 conntrack

# Generate default config and enable SystemdCgroup
containerd config default > /etc/containerd/config.toml
