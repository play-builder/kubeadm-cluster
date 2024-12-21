output "control_plane_public_ip" {
  description = "Control plane public IP address"
  value       = aws_instance.control_plane.public_ip
}

output "control_plane_private_ip" {
  description = "Control plane private IP address"
  value       = aws_instance.control_plane.private_ip
}

output "control_plane_instance_id" {
  description = "Control plane instance ID (for SSM access)"
  value       = aws_instance.control_plane.id
}

output "worker_instance_ids" {
  description = "Worker node instance IDs (for SSM access)"
  value       = [for w in aws_spot_instance_request.workers : w.spot_instance_id]
}

output "worker_public_ips" {
  description = "Worker node public IP addresses"
  value       = [for w in aws_spot_instance_request.workers : w.public_ip]
}

output "worker_private_ips" {
  description = "Worker node private IP addresses"
  value       = [for w in aws_spot_instance_request.workers : w.private_ip]
}

output "ssm_control_plane" {
  description = "SSM Session Manager command for control plane"
  value       = "aws ssm start-session --target ${aws_instance.control_plane.id} --region ${var.aws_region}"
}

output "ssm_workers" {
  description = "SSM Session Manager commands for worker nodes"
  value = [
    for i, w in aws_spot_instance_request.workers :
    "aws ssm start-session --target ${w.spot_instance_id} --region ${var.aws_region}  # worker-${i + 1}"
  ]
}

output "next_steps" {
  description = "Post-deployment instructions"
  value       = <<-EOT

    ================================================================
    Deployment complete! Follow these steps:
    ================================================================

    Step 1: Connect via SSM & wait for bootstrap (3-5 min)
      aws ssm start-session --target ${aws_instance.control_plane.id}
      sudo su - ubuntu
      tail -f /var/log/kubeadm-bootstrap.log

    Step 2: Install CNI plugin
      kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml

    Step 3: Get join command
      cat /home/ubuntu/join-command.sh

    Step 4: Connect to each worker via SSM and run join
      sudo <join command from step 3>

    Step 5: Verify
      kubectl get nodes
  EOT
}
