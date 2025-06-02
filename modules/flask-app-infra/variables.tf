# modules/flask-app/variables.tf

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 20
    error_message = "Project name must be between 1 and 20 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-central-1"
}

variable "container_image" {
  description = "Full ECR image URI for the container"
  type        = string
  
  validation {
    condition     = can(regex("^[0-9]+\\.dkr\\.ecr\\..+\\.amazonaws\\.com/.+:.+$", var.container_image))
    error_message = "Container image must be a valid ECR URI."
  }
}

variable "ecs_cpu" {
  description = "CPU units for ECS task (256, 512, 1024, etc.)"
  type        = number
  default     = 256
  
  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.ecs_cpu)
    error_message = "ECS CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "ecs_memory" {
  description = "Memory (MB) for ECS task"
  type        = number
  default     = 512
  
  validation {
    condition     = var.ecs_memory >= 512 && var.ecs_memory <= 30720
    error_message = "ECS memory must be between 512 MB and 30720 MB."
  }
}

variable "ecs_desired_count" {
  description = "Desired number of running ECS tasks"
  type        = number
  default     = 2
  
  validation {
    condition     = var.ecs_desired_count > 0 && var.ecs_desired_count <= 10
    error_message = "ECS desired count must be between 1 and 10."
  }
}

variable "container_port" {
  description = "Port on which the container application listens"
  type        = number
  default     = 5000
  
  validation {
    condition     = var.container_port > 0 && var.container_port <= 65535
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "alb_port" {
  description = "Port on which the Application Load Balancer listens"
  type        = number
  default     = 80
  
  validation {
    condition     = contains([80, 443, 8080], var.alb_port)
    error_message = "ALB port must be 80, 443, or 8080."
  }
}

variable "health_check_path" {
  description = "Health check endpoint path"
  type        = string
  default     = "/"
  
  validation {
    condition     = can(regex("^/.*", var.health_check_path))
    error_message = "Health check path must start with '/'."
  }
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks required"
  type        = number
  default     = 2
  
  validation {
    condition     = var.health_check_healthy_threshold >= 2 && var.health_check_healthy_threshold <= 10
    error_message = "Health check healthy threshold must be between 2 and 10."
  }
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
  
  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds."
  }
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
  
  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120
    error_message = "Health check timeout must be between 2 and 120 seconds."
  }
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks required"
  type        = number
  default     = 2
  
  validation {
    condition     = var.health_check_unhealthy_threshold >= 2 && var.health_check_unhealthy_threshold <= 10
    error_message = "Health check unhealthy threshold must be between 2 and 10."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
  }
}