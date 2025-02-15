# Route Tables
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.k8svpc.id

  route {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.k8s-nat.id
    }

  tags = {
    Name = "${var.eks_cluster_name}-private-rtb"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.k8svpc.id

  route {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.k8svpc-igw.id
    }

  tags = {
    Name = "${var.eks_cluster_name}-public-rtb"
  }
}


# Route Table Association
resource "aws_route_table_association" "private-us-west-2a" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-us-west-2b" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-us-west-2a" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-us-west-2b" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public.id
}

# Route Table Outputs
output "private-route-table-1"{
value = aws_route_table.private.id
}

output "public-route-table-1"{
value = aws_route_table.public.id
}