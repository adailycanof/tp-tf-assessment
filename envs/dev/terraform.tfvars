# Environment Configuration
project_name = "tp-assessment-sh"
environment  = "dev"

# AWS Configuration
aws_region = "eu-west-2"

# Container Configuration
container_image = "946760796955.dkr.ecr.eu-west-2.amazonaws.com/flask-tp-app:latest"

# ECS Configuration
ecs_cpu                = 256
ecs_memory            = 512
ecs_desired_count     = 2
container_port        = 5000

# Load Balancer Configuration
alb_port = 80

# Health Check Configuration
health_check_path               = "/"
health_check_healthy_threshold  = 2
health_check_interval          = 30
health_check_timeout           = 5
health_check_unhealthy_threshold = 2

# Tags
common_tags = {
  Environment = "dev"
  Project     = "tp-assessment-sh"
  ManagedBy   = "terraform"
}