variable "naming_prefix" {
  type        = string
  description = "Naming prefix for resources"
}

variable "vpc_id" {
  type        = string
  description = "Id of VPC"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block of VPC"
}

variable "vpc_public_subnets" {
  type        = map
  description = "a map of subnet id to cidr block, e.g. subnet_1234 => 10.0.1.0/4"
}

variable "vpc_private_subnets" {
  type        = map
  description = "a map of subnet id to cidr block, e.g. subnet_1234 => 10.0.1.0/4"
}

variable "instance_type_nginx" {
  type        = string
  description = "Type for EC2 Instance"
}

variable "instance_type_db" {
  type        = string
  description = "Type for EC2 Instance"
}

variable "instance_count_nginx" {
  type        = number
  description = "Number of nginx instances to create in VPC"
  default     = 2
}

variable "instance_count_db" {
  type        = number
  description = "Number of db instances to create in VPC"
}

variable "root_disk_size_nginx" {
  description = "The size of the root disk"
  default     = 10
}

variable "encrypted_disk_size_nginx" {
  description = "The size of the secondary encrypted disk"
  default     = 10
}

variable "encrypted_disk_device_name_nginx" {
  description = "The name of the device of secondary encrypted disk"
  type        = string
}

variable "volumes_type" {
  description = "The type of all the disk instances in my project"
  default     = "gp2"
}

variable "ubuntu_account_number" {
  default = "099720109477"
  type    = string
}

variable "key_name" {
  type        = string
  description = "key variable for refrencing"
}

variable "user_data_nginx" {
  type        = string
  description = "user_data for launching nginx"
}

variable "ami_nginx" {
  type        = string
  description = "ami of nginx instance"
}

variable "ami_db" {
  type        = string
  description = "ami of db instance"
}

variable "iam_instance_profile_nginx" {
  type        = string
  description = "iam instance profile"
}

variable "common_tags" {
  type        = map(string)
  description = "Map of tags to be applied to all resources"
  default     = {}
}