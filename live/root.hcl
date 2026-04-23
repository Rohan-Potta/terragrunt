generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.5.0, <= 1.14.8"
}

provider "aws" {
  region = "ap-south-2"
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket = "s3-terraform-backend-files-hyderabad"
    key    = "${path_relative_to_include()}/terragrunt/terraform.tfstate"
    region = "ap-south-2"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}