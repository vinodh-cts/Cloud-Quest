# Create a VPC
resource "aws_vpc" "k8svpc" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.eks_cluster_name}-vpc"
  }
}

# VPC Outputs
output "vpc"{
value = aws_vpc.k8svpc.id
}
