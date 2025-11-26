locals {
  oidc_bucket_name = var.oidc_bucket_name != "" ?
    var.oidc_bucket_name :
    "${var.project}-oidc-${data.aws_caller_identity.current.account_id}-${var.region}"
}

resource "aws_s3_bucket" "oidc" {
  bucket = local.oidc_bucket_name

  tags = {
    Name    = "${var.project}-oidc"
    Project = var.project
  }
}

# Allow public read of only the OIDC discovery + JWKS objects
resource "aws_s3_bucket_public_access_block" "oidc" {
  bucket                  = aws_s3_bucket.oidc.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "oidc_bucket_policy" {
  statement {
    sid       = "AllowPublicReadForOIDC"
    actions   = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.oidc.arn}/.well-known/openid-configuration",
      "${aws_s3_bucket.oidc.arn}/openid/v1/jwks",
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "oidc" {
  bucket = aws_s3_bucket.oidc.id
  policy = data.aws_iam_policy_document.oidc_bucket_policy.json
}

# ----- OIDC files -----

# 1) openid-configuration
locals {
  oidc_issuer_host = "${aws_s3_bucket.oidc.bucket}.s3.${var.region}.amazonaws.com"
  oidc_issuer_url  = "https://${local.oidc_issuer_host}"
}

resource "aws_s3_object" "oidc_openid_config" {
  bucket       = aws_s3_bucket.oidc.id
  key          = ".well-known/openid-configuration"
  content_type = "application/json"

  content = jsonencode({
    issuer  = local.oidc_issuer_url
    jwks_uri = "${local.oidc_issuer_url}/openid/v1/jwks"
  })

  acl = "public-read"
}

# 2) JWKS (provided as var.oidc_jwks_json)
resource "aws_s3_object" "oidc_jwks" {
  bucket       = aws_s3_bucket.oidc.id
  key          = "openid/v1/jwks"
  content_type = "application/json"

  content = var.oidc_jwks_json
  acl     = "public-read"
}

output "oidc_issuer_url" {
  value       = local.oidc_issuer_url
  description = "OIDC issuer URL hosted on S3"
}

output "oidc_bucket_name" {
  value       = aws_s3_bucket.oidc_openid_config.bucket
  description = "S3 bucket name hosting the OIDC issuer"
}
