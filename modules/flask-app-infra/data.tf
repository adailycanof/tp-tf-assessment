# Data calls

# Data source to get the VPC ID
data "aws_vpc" "default_vpc" {
}

# Data source to get the subnet ids
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default_vpc.id
}

# Data source to get the AWS-managed ECS Task Execution Role
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}