# Optional: explicit bucket name; otherwise we’ll generate one
variable "oidc_bucket_name" {
  type        = string
  default     = "aws-k8s-oidc-issuer"
  description = "S3 bucket name for OIDC issuer. If empty, a name will be generated."
}

# JWKS JSON for your OIDC issuer
# This must contain the public key that matches the key used by kube-apiserver
variable "oidc_jwks_json" {
  type        = string
  description = "JWKS JSON (contents of openid/v1/jwks)"
}

variable "aws_region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region to deploy resources"
}

variable "project_name" {
  type        = string
  default     = "k8s-cluster"
  description = "Name of the project"
}

variable "environment" {
  type        = string
  default     = "development"
  description = "Deployment environment (e.g., development, staging, production)"
}

variable "project" {
  type        = string
  default     = "vtd-devops-khangkieu"
  description = "Project identifier"
}

variable "owner" {
  type        = string
  default     = "khangkieu"
  description = "Owner of the resources"
}