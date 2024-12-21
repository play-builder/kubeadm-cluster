#!/bin/bash
##############################################################################
# control-plane.sh — Control Plane: Common packages + kubeadm init
##############################################################################
set -euxo pipefail

exec > >(tee /var/log/kubeadm-bootstrap.log) 2>&1

# Variables injected by Terraform templatefile
export NODE_HOSTNAME="${node_hostname}"
export KUBERNETES_VERSION="${kubernetes_version}"
CONTROL_PLANE_IP="${control_plane_ip}"
POD_NETWORK_CIDR="${pod_network_cidr}"

# Install common packages (containerd, kubeadm, kubelet, kubectl)
${common_script}

# Run kubeadm init
echo "=== kubeadm init started at $(date) ==="

kubeadm init \
  --apiserver-advertise-address="$CONTROL_PLANE_IP" \
  --pod-network-cidr="$POD_NETWORK_CIDR" \
  --node-name="$NODE_HOSTNAME" \
  --kubernetes-version="stable-$KUBERNETES_VERSION" \
  --upload-certs \
  2>&1 | tee /var/log/kubeadm-init.log

# Configure kubectl for root user
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config

# Configure kubectl for ubuntu user (available immediately after SSM login)
mkdir -p /home/ubuntu/.kube
cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Enable bash completion and alias
kubectl completion bash > /etc/bash_completion.d/kubectl
echo 'alias k=kubectl' >> /home/ubuntu/.bashrc
echo 'complete -o default -F __start_kubectl k' >> /home/ubuntu/.bashrc

# Save join command for worker nodes
kubeadm token create --print-join-command > /home/ubuntu/join-command.sh
chmod 644 /home/ubuntu/join-command.sh

echo "=== Bootstrap completed at $(date) ==="
