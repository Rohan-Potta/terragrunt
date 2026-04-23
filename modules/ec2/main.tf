resource "aws_instance" "example" {
  instance_type = var.instance_type
  ami = var.ami_id
  subnet_id = var.subnet_id

  tags = var.tags
}