terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.35.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "eu-central-1"
}