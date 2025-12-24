# --- Outputs ---
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID for the cluster"
}

output "private_subnet_ids" {
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  description = "Private subnet IDs (for control plane & workers)"
}

output "cluster_sg_id" {
  value       = aws_security_group.cluster.id
  description = "Cluster security group ID"
}
