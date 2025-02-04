provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "eks-terraform-tfstate-demo-2"
    key    = "services/test/terraform.tfstate"
    region = "us-east-1"
  }
}

terraform {
  required_version = "1.5.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}


