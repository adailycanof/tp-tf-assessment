# # ECR Repository
# resource "aws_ecr_repository" "app" {
#   name                 = "${var.project_name}-${var.environment}"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }

#   tags = merge(var.common_tags, {
#     Name = "${var.project_name}-${var.environment}-ecr"
#   })
# }