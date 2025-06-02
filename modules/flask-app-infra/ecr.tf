# ECR Repository

# Makes new ECR repo
resource "aws_ecr_repository" "app" {
  name                 = "flask-tp-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ecr"
  })
}