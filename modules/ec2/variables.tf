variable "instance_type" {
    description = "The type of instance to launch."
    type        = string
  
}

variable "tags" {
    description = "A map of tags to assign to the resource."
    type        = map(string)
    default     = {}
}

variable "subnet_id" {
    description = "The ID of the subnet to launch the instance in."
    type        = string
}

variable "ami_id" {
    description = "The ID of the AMI to use for the instance."
    type        = string
  
}
