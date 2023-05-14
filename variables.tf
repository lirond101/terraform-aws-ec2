#VPC vars
variable "vpc_id" {
  type        = string
  description = "Id of VPC"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block of VPC"
}

# variable "vpc_public_subnets" {
#   type        = map
#   description = "a map of subnet id to cidr block, e.g. subnet_1234 => 10.0.1.0/4"
# }

# variable "vpc_private_subnets" {
#   type        = map
#   description = "a map of subnet id to cidr block, e.g. subnet_1234 => 10.0.1.0/4"
# }

variable "vpc_public_subnets" {
  type = list(string)
  description = "Desired public_subnets as list of strings"
}

variable "vpc_private_subnets" {
  type = list(string)
  description = "Desired private_subnets as list of strings"
}

#INSTANCES vars
variable "instance_type" {
  type        = string
  description = "Type for EC2 Instance"
  default     = "t2.micro"
}

variable "instance_count_bastion" {
  default     = 1
  type        = number
  description = "Number of bastion instances to create in VPC"
}

variable "instance_count_consul" {
  type        = number
  description = "Number of consul instances to create in VPC"
}

variable "root_disk_size_bastion" {
  description = "The size of the root disk"
  default     = 20
}

variable "encrypted_disk_size_bastion" {
  description = "The size of the secondary encrypted disk"
  default     = 20
}

variable "root_disk_size_consul" {
  description = "The size of the root disk"
  default     = 10
}

variable "encrypted_disk_size_consul" {
  description = "The size of the secondary encrypted disk"
  default     = 10
}

variable "encrypted_disk_device_name" {
  description = "The name of the device of secondary encrypted disk"
  type        = string
  default     = "xvdh"
}

variable "volumes_type" {
  description = "The type of all the disk instances in my project"
  default     = "gp2"
}

variable "key_name" {
  type        = string
  description = "key variable for refrencing"
}

variable "user_data_consul" {
  type        = string
  description = "user_data for launching consul"
}

variable "ami_bastion" {
  type        = string
  description = "ami of bastion instance"
}

variable "ami_consul" {
  type        = string
  description = "ami of consul instance"
}

variable "iam_instance_profile_consul" {
  type        = string
  description = "iam instance profile"
}

variable "bastion_allowed_cidr_blocks" {
  type = list
  description = "allowed cidr blocks to connect bastion host from"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for resources"
}

variable "common_tags" {
  type        = map(string)
  description = "Map of tags to be applied to all resources"
  default     = {}
}