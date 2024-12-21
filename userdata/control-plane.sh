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
