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
#     SA_PRIVATE_KEY_PATH     = var.sa_private_key_path
#     SA_PUBLIC_KEY_PATH      = var.sa_public_key_path
#   })
# }


# An error occurred (AccessDeniedException) when calling the StartSession operation: User: arn:aws:sts::116981769322:assumed-role/vtd-devops-khangkieu-ec2-role/i-0a66c24bc771f3736 
# is not authorized to perform: ssm:StartSession on resource: arn:aws:ssm:ap-southeast-1:116981769322:document/SSM-SessionManagerRunShell because no identity-based policy allows the ssm:StartSession action

resource "aws_instance" "control_plane" {
  ami                    = data.aws_ami.ubuntu_jammy.id
  instance_type          = var.instance_type_cp
  subnet_id              = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.cluster.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = false
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null

#   user_data = base64encode(local.cp_user_data)

  ingress {
    description = "Allow all traffic within the SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  tags = {
    Name      = "${var.project}-cp"
    Project   = var.project_name
    Role      = "control-plane"
    ManagedBy = "terraform"
  }
}

output "control_plane_private_ip" {
  value = aws_instance.control_plane.private_ip
}
