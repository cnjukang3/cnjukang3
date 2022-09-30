terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region                   = var.region
  profile                  = var.sdl_aws_profile
  shared_config_files      = [var.shared_config_files]
  shared_credentials_files = [var.shared_credentials_files]

}