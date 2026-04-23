include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/ec2"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  instance_type = "t3.micro"
  tags = {
    Name = "prod-ec2"
    tag2 = "value2"
  }
  subnet_id = dependency.vpc.outputs.subnet_id
  ami_id    = "ami-0411ab208c7da4382"
}