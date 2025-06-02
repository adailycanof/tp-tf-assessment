terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.0"
    }
  }

  cloud {
    organization = "adco"
    workspaces {
      name = "devops-assessment-terraform"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "flask_app" {
  #source = "tp-tf-assessment/modules/flask-app-infra"
  #source = "../../modules/flask-app-infra"
  source = "../../modules/flask-app-infra"
  
  project_name        = var.project_name
  environment         = var.environment
  aws_region         = var.aws_region
  container_image    = var.container_image
  ecs_cpu           = var.ecs_cpu
  ecs_memory        = var.ecs_memory
  ecs_desired_count = var.ecs_desired_count
  container_port    = var.container_port
  alb_port          = var.alb_port
  
  health_check_path                = var.health_check_path
  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_interval           = var.health_check_interval
  health_check_timeout            = var.health_check_timeout
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
  
  common_tags = var.common_tags
}
