# --- Variables ---
variable "project" {
  type    = string
  default = "my-k8s"
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "oidc_jwks_json_path" {
  type        = string
  default     = "../keys/sa.jwks.json"
  description = "Path to JWKS JSON derived from sa_public_key_pem"
}
