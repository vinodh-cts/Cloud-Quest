variable "aws_region" {
        description = "AWS region for resources"
        type = string
}

variable "ecr_repository_name" {
        description = "List of ECR repositories to create"
        type = string
}