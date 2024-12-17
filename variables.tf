variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "cluster_name" {
  description = "Cluster name used for resource tagging"
  type        = string
  default     = "kubeadm-lab"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "ap-northeast-2a"
}

variable "control_plane_instance_type" {
  description = "EC2 instance type for the control plane node"
  type        = string
  default     = "t3.medium" # 2 vCPU, 4GB RAM
}

variable "worker_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.small" # 2 vCPU, 2GB RAM
}

variable "worker_count" {
  description = "Number of worker nodes to create"
  type        = number
  default     = 2
}

variable "ebs_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 30
}
variable "my_ip" {
  description = "Your public IP in CIDR notation for remote kubectl access (e.g. 203.0.113.1/32)"
  type        = string
}

variable "pod_network_cidr" {
  description = "Pod network CIDR for CNI plugin (Calico/Flannel)"
  type        = string
  default     = "10.244.0.0/16"
}

variable "kubernetes_version" {
  description = "Kubernetes version to install"
  type        = string
  default     = "1.31"
}

