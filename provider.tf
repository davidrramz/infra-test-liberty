terraform {
  backend "s3" {
    bucket         = "co-liberty-s3-terraform-state-bucket"
    dynamodb_table = "co-liberty-dynamoDB-terraform-state-table"
    key            = "global/statefile/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["../credentials"]
}