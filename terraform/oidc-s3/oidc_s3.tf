data "aws_caller_identity" "current" {}

locals {
  oidc_bucket_name = "${var.project}-oidc-${data.aws_caller_identity.current.account_id}-${var.region}"
}

resource "aws_s3_bucket" "oidc" {
  bucket = local.oidc_bucket_name

  tags = {
    Name    = "${var.project}-oidc"
    Project = var.project
  }
}

resource "aws_s3_bucket_public_access_block" "oidc" {
  bucket                  = aws_s3_bucket.oidc.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "oidc_bucket_policy" {
  statement {
    sid     = "AllowPublicReadForOIDC"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.oidc.arn}/.well-known/openid-configuration",
      "${aws_s3_bucket.oidc.arn}/openid/v1/jwks",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "oidc" {
  bucket = aws_s3_bucket.oidc.id
  policy = data.aws_iam_policy_document.oidc_bucket_policy.json
}

locals {
  oidc_issuer_url = "https://${aws_s3_bucket.oidc.bucket}.s3.${var.region}.amazonaws.com"
}

resource "aws_s3_object" "openid_configuration" {
  bucket       = aws_s3_bucket.oidc.id
  key          = ".well-known/openid-configuration"
  content_type = "application/json"

  content = jsonencode({
    issuer   = local.oidc_issuer_url
    jwks_uri = "${local.oidc_issuer_url}/openid/v1/jwks"
  })

}

resource "aws_s3_object" "jwks" {
  bucket       = aws_s3_bucket.oidc.id
  key          = "openid/v1/jwks"
  content_type = "application/json"

  content = file(var.oidc_jwks_json_path)
}

output "oidc_issuer_url" {
  value       = local.oidc_issuer_url
  description = "OIDC issuer URL (S3)"
}
