# NAT Gateway EIP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.eks_cluster_name}-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "k8s-nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "${var.eks_cluster_name}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.k8svpc-igw]
}
