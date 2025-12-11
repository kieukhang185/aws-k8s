data "aws_ami" "ubuntu_jammy" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"] 
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
}

# locals {
#   cp_user_data = templatefile("${path.module}/user_data/control-plane.sh.tmpl", {
#     POD_CIDR                = var.pod_cidr
#     AWS_REGION              = var.region
#     SSM_JOIN_PARAMETER_NAME = var.ssm_join_parameter_name
#     OIDC_ISSUER_URL         = var.oidc_issuer_url
#   })
# }

resource "aws_instance" "control_plane" {
  ami                    = data.aws_ami.ubuntu_jammy.id
  instance_type          = var.instance_type_cp
  subnet_id              = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.cluster.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = false
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null

#   user_data = base64encode(local.cp_user_data)

  tags = {
    Name      = "${var.project}-cp"
    Project   = var.project
    Role      = "control-plane"
    ManagedBy = "terraform"
  }
}

output "control_plane_private_ip" {
  value = aws_instance.control_plane.private_ip
}
