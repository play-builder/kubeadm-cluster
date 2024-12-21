# ── Control Plane Security Group ──

resource "aws_security_group" "control_plane" {
  name        = "${var.cluster_name}-control-plane-sg"
  description = "Control Plane: apiserver, etcd, kubelet, scheduler, controller-manager"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.cluster_name}-control-plane-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cp_apiserver_vpc" {
  security_group_id = aws_security_group.control_plane.id
  description       = "kube-apiserver from VPC"
  from_port         = 6443
  to_port           = 6443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_ingress_rule" "cp_apiserver_myip" {
  security_group_id = aws_security_group.control_plane.id
  description       = "kube-apiserver from my IP (remote kubectl)"
  from_port         = 6443
  to_port           = 6443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.my_ip
}

resource "aws_vpc_security_group_ingress_rule" "cp_etcd" {
  security_group_id            = aws_security_group.control_plane.id
  description                  = "etcd client and peer communication (self only)"
  from_port                    = 2379
  to_port                      = 2380
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.control_plane.id
}

resource "aws_vpc_security_group_ingress_rule" "cp_kubelet" {
  security_group_id = aws_security_group.control_plane.id
  description       = "kubelet API from VPC"
  from_port         = 10250
