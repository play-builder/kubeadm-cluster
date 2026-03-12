#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/kubeadm-bootstrap.log) 2>&1
echo "=== Bootstrap started at $(date) ==="

hostnamectl set-hostname "${NODE_HOSTNAME}"

swapoff -a
sed -i '/swap/d' /etc/fstab

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

apt-get update
# CHANGED: jq + basic debugging/networking tools added
apt-get install -y \
  ca-certificates curl gnupg \
  jq \
  net-tools \
  dnsutils \
  iputils-ping \
  tcpdump \
  traceroute \
  vim \
  htop \
  tree \
  wget \
  bash-completion

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

# --- containerd install (fixed: use apt-cache madison for exact version resolution) ---
CONTAINERD_VERSION=""
if CANDIDATES=$(apt-cache madison containerd.io 2>/dev/null); then
  # Try 2.2.x first, then fall back to latest available
  CONTAINERD_VERSION=$(echo "$CANDIDATES" | awk -F'|' '{gsub(/ /,"",$2); print $2}' | grep -m1 '^2\.2\.' || true)
fi

if [[ -n "$CONTAINERD_VERSION" ]]; then
  echo "Installing containerd.io=${CONTAINERD_VERSION}"
  apt-get install -y "containerd.io=${CONTAINERD_VERSION}" conntrack
else
  echo "WARN: containerd 2.2.x not found, installing latest available"
  apt-get install -y containerd.io conntrack
fi

containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_VERSION}/deb/Release.key" | \
  gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
  https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_VERSION}/deb/ /" | \
  tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable kubelet

cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF

# ADDED: shell aliases (k=kubectl, c=crictl, d=docker) with bash completion
kubectl completion bash > /etc/bash_completion.d/kubectl
crictl completion bash > /etc/bash_completion.d/crictl
command -v docker &>/dev/null && docker completion bash > /etc/bash_completion.d/docker || true

cat >> /home/ubuntu/.bashrc <<'ALIAS_EOF'
alias k=kubectl
complete -o default -F __start_kubectl k
alias c=crictl
complete -o default -F __start_crictl c
alias d=docker
command -v docker &>/dev/null && complete -o default -F __start_docker d
ALIAS_EOF

echo "=== Common setup completed at $(date) ==="
