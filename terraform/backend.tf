# Terraform Backend Configuration
# S3 Bucket for Terraform State
resource "aws_s3_bucket" "tf_state" {
  bucket = "terraform-state-bucket"
  acl    = "private"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.use_existing_kms ? var.existing_kms_state_id : aws_kms_key.s3_state.id
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state_public_access" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_lifecycle_configuration" "tf_state_lifecycle" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    id     = "retain-older-state-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      days          = 90
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 365
    }
    filter {}
  }

  rule {
    id     = "expire-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    filter {}
  }
}

# DynamoDB Table for Terraform State Locking
resource "aws_dynamodb_table" "tf_state_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name        = "Terraform State Lock Table"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }
}

# Outputs
output "state_bucket_name" {
  value       = aws_s3_bucket.tf_state.id
  sensitive   = true
  description = "The name of the Terraform state S3 bucket"
  depends_on  = [aws_s3_bucket.tf_state]
}

output "state_lock_table_name" {
  value       = aws_dynamodb_table.tf_state_lock.name
  sensitive   = true
  description = "The name of the DynamoDB table for Terraform state locking"
  depends_on  = [aws_dynamodb_table.tf_state_lock]
}
