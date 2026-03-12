#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/kubeadm-bootstrap.log) 2>&1

export NODE_HOSTNAME="${node_hostname}"
export KUBERNETES_VERSION="${kubernetes_version}"

${common_script}

# ADDED: Install latest stable Docker CE (repo already configured in common.sh)
echo "=== Installing Docker CE at $(date) ==="
apt-get install -y docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin
usermod -aG docker ubuntu
systemctl enable docker

echo "=== Worker setup completed at $(date) ==="
echo "=== Run 'kubeadm join' manually after checking join-command.sh on the control plane ==="
