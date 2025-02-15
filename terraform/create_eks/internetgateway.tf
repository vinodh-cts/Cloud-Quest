# Internet gateway
resource "aws_internet_gateway" "k8svpc-igw" {
  vpc_id = aws_vpc.k8svpc.id

  tags = {
    Name = "${var.eks_cluster_name}-igw"
  }
}

# Internet Gateway Outputs
output "internet_gateway"{
value = aws_internet_gateway.k8svpc-igw.id
}