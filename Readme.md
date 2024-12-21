# kubeadm-cluster

Terraform으로 AWS에 kubeadm 기반 Kubernetes 클러스터를 프로비저닝하는 IaC 프로젝트.

EKS 대신 kubeadm을 사용하여 Kubernetes 내부 구조(etcd, apiserver, scheduler, controller-manager)를 학습하기 위한 샌드박스 환경

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.5.0
- Your public IP (`curl -s ifconfig.me`)


## Quick Start
```bash
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

# 6. Install CNI (Calico)
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml

# 7. Join workers (run on each worker node)
# Get join command from control plane:
cat /home/ubuntu/join-command.sh
# Then on each worker via SSM:
sudo <paste join command>

# 8. Verify
kubectl get nodes
```

## Cleanup

```bash
terraform destroy
```


## Tech Stack
| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | >= 1.5.0 | Infrastructure as Code |
| AWS Provider | ~> 5.0 | AWS 리소스 관리 |
| Kubernetes | 1.31 | Container orchestration |
| containerd | v2.0.0 | CRI runtime |
| Calico | v3.28.0 | CNI plugin (pod networking) |
| Ubuntu | 22.04 LTS (Jammy) | Node OS |