terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.11.0"
    }
  }
}

terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket  = "cresset-github-runner-test"
    key     = "test/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = "eu-west-2"
}