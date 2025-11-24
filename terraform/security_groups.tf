
resource "aws_secrity_group" "allow_tls" {
  name        = "${var.project_name}-allow-tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id
  tag = {
    Name        = "${var.project_name}-allow-tls"
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "aws_security_group_ingress_rule" "allow_tls_ipv4" {
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.allow_tls.id
  cidr_blocks       = [aws_vpc.main.cidr_block]
}

resource "aws_security_group_ingress_rule" "allow_tls_ipv6" {
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.allow_tls.id
  ipv6_cidr_blocks  = aws_vpc.main.ipv6_cidr_block_association_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.allow_tls.id
  cidr_blocks       = [aws_vpc.main.cidr_block]
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.allow_tls.id
  ipv6_cidr_blocks  = [aws_vpc.main.ipv6_cidr_block_association_id]
}
