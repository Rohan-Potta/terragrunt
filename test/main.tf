module "vpc" {
  source = "../modules/vpc"

  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "test"
  }
  subnet_cidr_block = "10.0.1.0/24"
  subnet_tags = {
    Name = "subnet-test"
  }

}

module "ec2" {
  source = "../modules/ec2"

  instance_type = "t3.micro"
  subnet_id     = module.vpc.subnet_id
  ami_id = "ami-0411ab208c7da4382" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  tags = {
    Name = "instance-test"
  }
}


