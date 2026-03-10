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
  to_port           = 10250
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_ingress_rule" "cp_controller_manager" {
  security_group_id = aws_security_group.control_plane.id
  description       = "kube-controller-manager health check"
  from_port         = 10257
  to_port           = 10257
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_ingress_rule" "cp_scheduler" {
  security_group_id = aws_security_group.control_plane.id
  description       = "kube-scheduler health check"
  from_port         = 10259
  to_port           = 10259
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "cp_all_outbound" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Allow all outbound (apt, image pull, SSM)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "worker" {
  name        = "${var.cluster_name}-worker-sg"
  description = "Worker Node: kubelet API, NodePort services"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.cluster_name}-worker-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "wk_kubelet" {
  security_group_id = aws_security_group.worker.id
  description       = "kubelet API from VPC"
  from_port         = 10250
  to_port           = 10250
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_ingress_rule" "wk_nodeport" {
  security_group_id = aws_security_group.worker.id
  description       = "NodePort services (sandbox, open to public)"
  from_port         = 30000
  to_port           = 32767
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "wk_inter_worker" {
  security_group_id            = aws_security_group.worker.id
  description                  = "Inter-worker pod network (CNI overlay)"
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.worker.id
}

resource "aws_vpc_security_group_ingress_rule" "wk_from_cp" {
  security_group_id            = aws_security_group.worker.id
  description                  = "All traffic from control plane"
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.control_plane.id
}

resource "aws_vpc_security_group_ingress_rule" "cp_from_wk" {
  security_group_id            = aws_security_group.control_plane.id
  description                  = "All traffic from workers (pod network)"
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.worker.id
}

resource "aws_vpc_security_group_egress_rule" "wk_all_outbound" {
  security_group_id = aws_security_group.worker.id
  description       = "Allow all outbound (apt, image pull, SSM)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}