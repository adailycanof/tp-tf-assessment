# Data sources
data "aws_iam_role" "task_ecs" {
  name = "ecsTaskExecutionRole"
}

data "aws_vpc" "default_vpc" {
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

data "aws_subnet_ids" "default" {
  # either specify the VPC directly…
  vpc_id = data.aws_vpc.default_vpc.id
}