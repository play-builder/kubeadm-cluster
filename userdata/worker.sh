#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/kubeadm-bootstrap.log) 2>&1

export NODE_HOSTNAME="${node_hostname}"
export KUBERNETES_VERSION="${kubernetes_version}"

${common_script}

echo "=== Worker setup completed at $(date) ==="
echo "=== Run 'kubeadm join' manually after checking join-command.sh on the control plane ==="