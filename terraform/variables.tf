# --- Variables ---
variable "project" {
  type    = string
  default = "my-k8s"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "owner" {
  type    = string
  default = "khangkieu"
}

variable "project_name" {
  type    = string
  default = "vtd-devops-khangkieu"
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

# If you use existing VPC, set these IDs; otherwise define them in vpc.tf
# variable "vpc_id"             { type = string }
# variable "private_subnet_ids" { type = list(string) }
# variable "cluster_sg_id"      { type = string }

variable "instance_type_cp" {
  type    = string
  default = "t3.medium"
}

variable "instance_type_wk" {
  type    = string
  default = "t3.small"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "key_pair_name" {
  type    = string
  default = "khangkieu"
}

variable "pod_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "ssm_join_parameter_name" {
  type    = string
  default = "/kubeadm/join"
}

# OIDC bits
variable "sa_private_key_path" {
  type        = string
  description = "Path to service-account private key PEM file"
}

variable "sa_public_key_path" {
  type        = string
  description = "PEM content of service-account public key"
}

variable "oidc_jwks_json_path" {
  type        = string
  description = "Path to JWKS JSON derived from sa_public_key_pem"
}

variable "oidc_thumbprint" {
  type        = string
  description = "SHA1 thumbprint of the S3 HTTPS cert"
}

variable "use_existing_kms" {
  type    = bool
  default = false
}

variable "existing_kms_id" {
  type    = string
  default = ""
}

variable "oidc_issuer_url" {
  type    = string
  default = ""
}