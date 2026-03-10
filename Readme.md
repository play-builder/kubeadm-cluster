# kubeadm-cluster

Terraform으로 AWS에 kubeadm 기반 Kubernetes 클러스터를 프로비저닝하는 IaC 프로젝트.

EKS 대신 kubeadm을 사용하여 Kubernetes 내부 구조(etcd, apiserver, scheduler, controller-manager)를 학습하기 위한 샌드박스 환경

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.5.0
- Your public IP (`curl -s ifconfig.me`)

### Quick Start

# 1. Clone

git clone https://github.com/play-builder/kubeadm-cluster.git
cd kubeadm-cluster

# 2. Configure

cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars — set my_ip to your public IP

# 3. Deploy

terraform init
terraform plan
terraform apply

# 4. Connect to control plane via SSM

aws ssm start-session --target <instance-id>
sudo su - ubuntu

# 5. Wait for bootstrap to complete (~3-5 min)

tail -f /var/log/kubeadm-bootstrap.log

# 6. Verify Calico CNI (auto-installed via Tigera Operator)

kubectl get tigerastatus  
kubectl get pods -n calico-system

# 7. Join workers (run on each worker node)

cat /home/ubuntu/join-command.sh
sudo <paste join command>

# 8. Verify

kubectl get nodes

## Cleanup

terraform destroy

## Tech Stack

| Tool         | Version   | Purpose                     |
| ------------ | --------- | --------------------------- |
| Terraform    | >= 1.5.0  | Infrastructure as Code      |
| AWS Provider | ~> 6.0    | AWS resource management     |
| Kubernetes   | 1.35      | Container orchestration     |
| containerd   | v2.2.x    | CRI runtime                 |
| Calico       | v3.31.4   | CNI plugin (pod networking) |
| Ubuntu       | 24.04 LTS | Node OS                     |
