# --- EC2 IAM Roles and Policies ---
data "aws_caller_identity" "current" {}
# IAM Role and Instance Profile for EC2 Instances
data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.project}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json

  tags = {
    Name        = "${var.project}-ec2-role"
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_ro" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# IAM for KUBE join
data "aws_iam_policy_document" "param_rw_assume_role_policy" {
  # ssm start session
  statement {
    actions = ["ec2:*", "ssm:StartSession"]
    resources = [
      "arn:aws:ssm:*:*:document/SSM-SessionManagerRunShell",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"
    ]
  }
  statement {
    actions   = ["ssm:PutParameter"]
    resources = ["arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/k8s/join"]
  }
  statement {
    actions   = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = ["arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/k8s/join"]
  }
}

resource "aws_iam_policy" "param_rw_role" {
  name   = "${var.project}-param-rw-role"
  policy = data.aws_iam_policy_document.param_rw_assume_role_policy.json
  tags = {
    Name        = "${var.project}-param-rw-role"
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "param_rw_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.param_rw_role.arn
}

# IAM for s3 access
# data "aws_iam_policy_document" "s3_access_assume_role_policy" {
#     statement {
#         actions = ["s3:ListBucket"]
#         resources = ["arn:aws:s3:::${var.s3_bucket_name}"]
#     }
#     statement {
#         actions = ["s3:GetObject","s3:PutObject","s3:DeleteObject"]
#         resources = ["arn:aws:s3:::${var.s3_bucket_name}/*"]
#     }
# }


# OIDC provider (server URL comes from your cluster; supply data via kubernetes/auth or pass manually)
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url = var.oidc_issuer_url
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint]
}
