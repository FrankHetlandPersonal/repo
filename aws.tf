# Sets the provider and alias
provider "aws" {
  alias  = "eu-north-1"
  region = "eu-north-1"
}
# The root module configuration block for Terraform
terraform {
  backend "s3" {
    region = "eu-north-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22.0"
    }
  }
}
