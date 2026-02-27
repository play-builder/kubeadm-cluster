variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "cluster_name" {
  description = "Cluster name used for resource tagging"
  type        = string
  default     = "kubeadm-lab"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.cluster_name))
    error_message = "cluster_name must be lowercase alphanumeric with hyphens, 2-63 characters."
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 0))
    error_message = "public_subnet_cidr must be a valid CIDR block."
  }
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "ap-northeast-2a"
}

variable "control_plane_instance_type" {
  description = "EC2 instance type for the control plane node (minimum 2 vCPU, 2GB RAM)"
  type        = string
  default     = "t3.medium"
}

variable "worker_instance_type" {
  description = "EC2 instance type for worker nodes (minimum 2 vCPU, 2GB RAM)"
  type        = string
  default     = "t3.small"
}

variable "worker_count" {
  description = "Number of worker nodes to create"
  type        = number
  default     = 2

  validation {
    condition     = var.worker_count >= 1 && var.worker_count <= 10
    error_message = "worker_count must be between 1 and 10."
  }
}

variable "ebs_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.ebs_volume_size >= 20
    error_message = "ebs_volume_size must be at least 20 GB for Kubernetes nodes."
  }
}

variable "my_ip" {
  description = "Your public IP in CIDR notation for remote kubectl access (e.g. 203.0.113.1/32)"
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip, 0))
    error_message = "my_ip must be a valid CIDR notation (e.g. 203.0.113.1/32)."
  }
}

variable "pod_network_cidr" {
  description = "Pod network CIDR for Calico CNI plugin"
  type        = string
  default     = "10.244.0.0/16"

  validation {
    condition     = can(cidrhost(var.pod_network_cidr, 0))
    error_message = "pod_network_cidr must be a valid CIDR block."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes minor version to install (e.g. 1.35)"
  type        = string
  default     = "1.35"

  validation {
    condition     = can(regex("^1\\.(3[3-9]|[4-9][0-9])$", var.kubernetes_version))
    error_message = "kubernetes_version must be a supported minor version (>= 1.33)."
  }
}

variable "calico_version" {
  description = "Calico version to install via Tigera Operator"
  type        = string
  default     = "3.31.4"

  validation {
    condition     = can(regex("^3\\.[2-9][0-9]\\.[0-9]+$", var.calico_version))
    error_message = "calico_version must be a valid Calico 3.x version (e.g. 3.31.4)."
  }
}