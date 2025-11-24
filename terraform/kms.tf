
data "aws_caller_identity" "current" {}

resource "aws_kms_key" "s3_state" {
  count                   = var.use_existing_kms == false ? 1 : 0
  description             = "A new KMS key managed by Terraform"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_s3_state.json

  tags = {
    Name        = "${var.project_name}-kms-key"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}

resource "aws_kms_key" "s3_logs" {
  count                   = var.use_existing_kms == false ? 1 : 0
  description             = "KMS key for S3 access logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_s3_logs.json

  tags = {
    Name        = "${var.project_name}-s3-logs-kms-key"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}

data "aws_kms_key" "existing_s3_state" {
  count  = var.use_existing_kms == true ? 1 : 0
  key_id = var.existing_kms_id
}

data "aws_kms_key" "existing_s3_logs" {
  count  = var.use_existing_kms == true ? 1 : 0
  key_id = var.existing_kms_id
}

resource "aws_kms_alias" "s3_state" {
  count         = var.use_existing_kms == false ? 1 : 0
  name          = "alias/terraform-state-key"
  target_key_id = aws_kms_key.new[0].id
}

resource "aws_kms_alias" "s3_logs" {
  name          = "alias/s3-logs-kms"
  target_key_id = aws_kms_key.s3_logs.key_id
}

data "aws_iam_policy_document" "kms_s3_state" {
  statement {
    sid    = "EnableRootAdmin"
    effect = "Allow"
    actions = [
      "kms:*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = ["*"]
  }

  # Allow use of the CMK by IAM policies in this account
  statement {
    sid    = "AllowUseFromThisAccount"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy_document" "kms_s3_logs" {
  statement {
    sid    = "EnableRootAdmin"
    effect = "Allow"
    actions = [
      "kms:*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = ["*"]
  }
  statement {
    sid    = "AllowUseFromThisAccount"
    effect = "Allow"
    acctions = [
      "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }
}
