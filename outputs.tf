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
