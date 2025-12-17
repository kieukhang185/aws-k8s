########################
# Security Group for K8s nodes
########################

resource "aws_security_group" "cluster" {
  name        = "${var.project}-cluster-sg"
  description = "Security group for Kubernetes control plane and workers"
  vpc_id      = aws_vpc.main.id

  # Intra-SG: allow all traffic between nodes
  ingress {
    description = "Allow all traffic within the SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # NodePort range from your IP (replace x.x.x.x/32 with your public IP)
  ingress {
    description = "NodePort access from admin IP"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["18.207.229.15/32"]
  }

  # allow 6443 from worker SG
  ingress {
    description = "API server from worker nodes"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    security_groups = [aws_security_group.worker.id]
  }

  # (Optional) SSH from your IP, if you want direct SSH in addition to SSM
  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project}-cluster-sg"
    Project = var.project_name
  }
}
