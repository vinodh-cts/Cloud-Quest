# Availability Zones Data Source
data "aws_availability_zones" "available" {}

# Private Subnet 01
resource "aws_subnet" "private-subnet-1" {
  vpc_id            = aws_vpc.k8svpc.id
  cidr_block        = "192.168.0.0/19"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name                                            = "${var.eks_cluster_name}-private-subnet-1"
    "kubernetes.io/role/internal-elb"               = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Private Subnet 02
  resource "aws_subnet" "private-subnet-2" {
  vpc_id            = aws_vpc.k8svpc.id
  cidr_block        = "192.168.32.0/19"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name                                            = "${var.eks_cluster_name}-private-subnet-2"
    "kubernetes.io/role/internal-elb"               = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Public Subnet 01
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.k8svpc.id
  cidr_block              = "192.168.64.0/19"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name                                            = "${var.eks_cluster_name}-public-subnet-1" 
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Public Subnet 02
resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.k8svpc.id
  cidr_block              = "192.168.96.0/19"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name                                            = "${var.eks_cluster_name}-public-subnet-2" 
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Subnet Outputs
output "private-subnet1"{
value = aws_subnet.private-subnet-1.id
}

output "private-subnet2"{
value = aws_subnet.private-subnet-2.id
}

output "public-subnet1"{
value = aws_subnet.public-subnet-1.id
}

output "public-subnet2"{
value = aws_subnet.public-subnet-2.id
}