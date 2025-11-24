# Variable definitions for Terraform configuration

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

variable "kubernetes_version" {
  type        = string
  default     = "1.31"
  description = "Version of Kubernetes to deploy"
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "Type of AWS EC2 instance to use"
}

variable "node_count" {
  type        = number
  default     = 2
  description = "Number of worker nodes in the Kubernetes cluster"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "storage_class" {
  type        = string
  default     = "gp3"
  description = "EBS storage class type"
}

variable "storage_size" {
  type        = number
  default     = 20
  description = "Size of the EBS volume in GB"
}

variable "pod_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "CIDR block for the Kubernetes pods"
}

variable "systemd_cgroup" {
  type        = bool
  default     = true
  description = "Whether to enable SystemdCgroup for containerd"
}

variable "use_existing_vpc" {
  type        = bool
  default     = false
  description = "Whether to use an existing VPC"
}

variable "existing_vpc_id" {
  type        = string
  default     = ""
  description = "ID of the existing VPC to use if use_existing_vpc is true"
}

variable "use_existing_kms" {
  type        = bool
  default     = false
  description = "Whether to use an existing KMS key"
}

variable "existing_kms_state_id" {
  type        = string
  default     = ""
  description = "ID of the existing KMS key to use if use_existing_kms is true"
}

variable "existing_kms_logs_id" {
  type        = string
  default     = ""
  description = "ID of the existing KMS key to use if use_existing_kms is true"
}
