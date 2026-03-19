# ec2.tf

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  common_script = file("${path.module}/userdata/common.sh")
}

resource "aws_instance" "control_plane" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.control_plane_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.control_plane.id]
  private_ip             = "10.0.1.10"
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  associate_public_ip_address = true
  source_dest_check           = false

  root_block_device {
    volume_size           = var.ebs_volume_size
    volume_type           = "gp3"
    delete_on_termination = true

    tags = {
      Name = "${var.cluster_name}-control-plane-ebs"
    }
  }

  user_data = templatefile("${path.module}/userdata/control-plane.sh", {
    node_hostname      = "cp"
    kubernetes_version = var.kubernetes_version
    control_plane_ip   = "10.0.1.10"
    pod_network_cidr   = var.pod_network_cidr
    calico_version     = var.calico_version
    common_script      = local.common_script
  })

  lifecycle {
    ignore_changes = [user_data, ami]
  }

  tags = {
    Name = "${var.cluster_name}-control-plane"
    Role = "control-plane"
  }
}

resource "aws_spot_instance_request" "workers" {
  count = var.worker_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.worker_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.worker.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  associate_public_ip_address = true
  source_dest_check           = false

  spot_type            = "one-time"
  wait_for_fulfillment = true

  root_block_device {
    volume_size           = var.ebs_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/userdata/worker.sh", {
    node_hostname      = "wk${count.index + 1}"
    kubernetes_version = var.kubernetes_version
    common_script      = local.common_script
  })

  lifecycle {
    ignore_changes = [user_data, ami]
  }

  tags = {
    Name = "${var.cluster_name}-worker-${count.index + 1}"
    Role = "worker"
  }
}

# ADDED: Fix spot instance source_dest_check not propagated to actual EC2 instance
resource "terraform_data" "worker_source_dest_check" {
  count = var.worker_count

  triggers_replace = [aws_spot_instance_request.workers[count.index].spot_instance_id]

  provisioner "local-exec" {
    command = <<-EOT
      aws ec2 modify-instance-attribute \
        --instance-id ${aws_spot_instance_request.workers[count.index].spot_instance_id} \
        --no-source-dest-check \
        --region ${var.aws_region}
    EOT
  }

  depends_on = [aws_spot_instance_request.workers]
}
