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
