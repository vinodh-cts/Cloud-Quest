# Create ECR repository
resource "aws_ecr_repository" "quest_repos" {
	name = var.ecr_repository_name
	image_tag_mutability = "MUTABLE"
	image_scanning_configuration {
		scan_on_push = false
	}
}