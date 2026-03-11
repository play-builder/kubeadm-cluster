#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/kubeadm-bootstrap.log) 2>&1

export NODE_HOSTNAME="${node_hostname}"
export KUBERNETES_VERSION="${kubernetes_version}"
CONTROL_PLANE_IP="${control_plane_ip}"
POD_NETWORK_CIDR="${pod_network_cidr}"
CALICO_VERSION="${calico_version}"

${common_script}

echo "=== kubeadm init started at $(date) ==="

kubeadm init \
  --apiserver-advertise-address="$CONTROL_PLANE_IP" \
  --pod-network-cidr="$POD_NETWORK_CIDR" \
  --node-name="$NODE_HOSTNAME" \
  --kubernetes-version="stable-$KUBERNETES_VERSION" \
  --upload-certs \
  2>&1 | tee /var/log/kubeadm-init.log

# --- kubeconfig setup (explicit KUBECONFIG export for userdata context) ---
export KUBECONFIG=/etc/kubernetes/admin.conf

mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config

mkdir -p /home/ubuntu/.kube
cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

kubectl completion bash > /etc/bash_completion.d/kubectl
echo 'alias k=kubectl' >> /home/ubuntu/.bashrc
echo 'complete -o default -F __start_kubectl k' >> /home/ubuntu/.bashrc

# --- Wait for API server to be fully ready ---
echo "=== Waiting for API server readiness at $(date) ==="
for i in $(seq 1 30); do
  if kubectl get --raw /readyz &>/dev/null; then
    echo "API server is ready (attempt $i)"
    break
  fi
  echo "Waiting for API server... (attempt $i/30)"
  sleep 5
done

echo "=== Installing Calico v$CALICO_VERSION via Tigera Operator at $(date) ==="

kubectl create -f "https://raw.githubusercontent.com/projectcalico/calico/v$CALICO_VERSION/manifests/tigera-operator.yaml"

echo "Waiting for Tigera Operator deployment..."
kubectl rollout status deployment/tigera-operator -n tigera-operator --timeout=120s || true

echo "Waiting for Tigera CRDs to be registered..."
for i in $(seq 1 60); do
  if kubectl get crd installations.operator.tigera.io &>/dev/null && \
     kubectl get crd apiservers.operator.tigera.io &>/dev/null; then
    echo "Tigera CRDs are ready (attempt $i)"
    break
  fi
  echo "Waiting for CRDs... (attempt $i/60)"
  sleep 5
done

cat <<CALICO_EOF | kubectl create -f -
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: $POD_NETWORK_CIDR
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
CALICO_EOF

echo "=== Calico Operator installation initiated at $(date) ==="
echo "=== Run 'kubectl get tigerastatus' to check readiness ==="

kubeadm token create --print-join-command > /home/ubuntu/join-command.sh
chmod 644 /home/ubuntu/join-command.sh

echo "=== Bootstrap completed at $(date) ==="
