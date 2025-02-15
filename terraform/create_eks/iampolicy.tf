# Create an IAM policy from a JSON file
resource "aws_iam_policy" "node_iam_policy" {
  name        = "${var.eks_cluster_name}-node-role-policy"
  description = "IAM Policy for Node Group IAM Role"
  policy      = file("${path.module}/node-group-policy.json")
}
