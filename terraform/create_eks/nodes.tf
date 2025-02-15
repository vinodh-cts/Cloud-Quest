# Node Group Role and Trust Policy
resource "aws_iam_role" "nodes" {
  name = "${var.eks_cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = ["ec2.amazonaws.com", "eks.amazonaws.com"]
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach the policy to an IAM role
resource "aws_iam_role_policy_attachment" "node_iam_policy_attachment" {
  role       = "${var.eks_cluster_name}-node-role"
  policy_arn = aws_iam_policy.node_iam_policy.arn
}

# IAM Policy attachment to Nodegroup Role
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}


# Private Node Group
resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.eks_cluster_name}-private-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private-subnet-1.id,
    aws_subnet.private-subnet-2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = var.nodegroup_instance_types
  remote_access {
    ec2_ssh_key = var.ssh_key_name
  } 
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    app = "backend"
  }
  tags = {
      Name = "backend"
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Public Node Group
resource "aws_eks_node_group" "public-nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.eks_cluster_name}-public-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.public-subnet-1.id,
    aws_subnet.public-subnet-2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = var.nodegroup_instance_types
  remote_access {
    ec2_ssh_key = var.ssh_key_name
  } 
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    app = "frontend"
  }
    tags = {
      Name = "frontend"
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}
