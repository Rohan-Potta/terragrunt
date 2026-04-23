include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "prod-vpc"
    tag2 = "value2"
  }

  subnet_cidr_block = "10.0.1.0/24"

  subnet_tags = {
    Name = "prod-subnet"
    tag4 = "value4"
  }
}