terraform {
  required_version = ">= 0.12.0"

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
  region = "eu-west-2"
}