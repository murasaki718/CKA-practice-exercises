terraform {
  cloud {
    organization = "ORG"

    workspaces {
      name = "WORKSPACE"
    }
  }

  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}