variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "nodegroup_instance_types" {
  description = "List of EC2 instance types to use for the EKS node group"
  type        = list(string)
}