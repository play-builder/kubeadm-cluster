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

