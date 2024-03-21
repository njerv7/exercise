// Declare the providers

terraform {
  backend "s3" {
    bucket = "natest-terraform-state"
    key    = "exercise/aws_infra"
    region = "eu-west-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.41.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.0"
    }
  }

  required_version = ">= 1.7.5"
}

// Define the aws region to deploy to, taking default from variables.tf

provider "aws" {
  profile                  = "default"
  region                   = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
}

provider "aws" {
  alias                    = "other"
  profile                  = "other"
  region                   = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
}