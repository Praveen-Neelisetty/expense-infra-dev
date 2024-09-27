terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.64.0"
    }
  }

  backend "s3" {
    bucket         = "praveen-remote-state-s3"
    key            = "expense-dev-sg-infra"
    region         = "us-east-1"
    dynamodb_table = "remote-state-s3-locking"
  }
}

provider "aws" {
  region = "us-east-1"
}

