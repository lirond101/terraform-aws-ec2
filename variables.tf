#
variable "instance_type" {
  type        = string
  description = "Type for EC2 Instance"
  default     = "t2.micro"
}
#
variable "instance_count_nginx" {
  type        = number
  description = "Number of nginx instances to create in VPC"
  default     = 2
}

variable "instance_count_db" {
  type        = number
  description = "Number of db instances to create in VPC"
  default     = 2
}
#
variable "nginx_root_disk_size" {
  description = "The size of the root disk"
  default     = 10
}
#
variable "nginx_encrypted_disk_size" {
  description = "The size of the secondary encrypted disk"
  default     = 10
}
#
variable "nginx_encrypted_disk_device_name" {
  description = "The name of the device of secondary encrypted disk"
  default     = "xvdh"
  type        = string
}
#
variable "volumes_type" {
  description = "The type of all the disk instances in my project"
  default     = "gp2"
}
#
variable "ubuntu_account_number" {
  default = "099720109477"
  type    = string
}
#
variable "key_name" {
  type        = string
  description = "key variable for refrencing"
  default     = "ec2Key2"
}

variable "user_data_nginx" {
  type        = string
  description = "user_data for launching nginx"
}

variable "subnet_id_nginx" {
  type        = string
  description = "subnet id of public subnet"
}

variable "subnet_id_db" {
  type        = string
  description = "subnet id of private subnet"
}

variable "ami" {
  type        = string
  description = "ami of instance"
}

variable "nginx_iam_instance_profile" {
  type        = string
  description = "iam instance profile"
}

variable "common_tags" {
  type        = map(string)
  description = "Map of tags to be applied to all resources"
  default     = {}
}