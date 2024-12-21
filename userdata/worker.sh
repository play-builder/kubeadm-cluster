#!/bin/bash
# worker.sh — Worker Node: Common packages only (join is manual)
set -euxo pipefail

exec > >(tee /var/log/kubeadm-bootstrap.log) 2>&1

# Variables injected by Terraform templatefile
export NODE_HOSTNAME="${node_hostname}"
export KUBERNETES_VERSION="${kubernetes_version}"

# Install common packages (containerd, kubeadm, kubelet, kubectl)
${common_script}

echo "=== Worker setup completed at $(date) ==="
echo "=== Run 'kubeadm join' manually after checking join-command.sh on the control plane ==="
