# Terraform Backend Configuration
# Using local backend for development (will work for solo projects)

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local backend (state stored on your machine)
  # For production teams, use S3 + DynamoDB for state locking
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "CloudDeploymentPlatform"
      ManagedBy   = "Terraform"
      Owner       = "Durgesh"
      Environment = var.environment
      Purpose     = "Portfolio"
    }
  }
}
