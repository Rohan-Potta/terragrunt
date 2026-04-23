variable "cidr_block" {
    description = "The CIDR block for the VPC."
    type        = string
  
}

variable "tags" {
    description = "A map of tags to assign to the resource."
    type        = map(string)
    default     = {}
}

variable "subnet_cidr_block" {
    description = "The CIDR block for the subnet."
    type        = string
  
}

variable "subnet_tags" {
    description = "A map of tags to assign to the subnet."
    type        = map(string)
    default     = {}
  
}