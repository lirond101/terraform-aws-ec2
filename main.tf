# NGINX #
resource "aws_instance" "nginx" {
  depends_on = [
    aws_security_group.nginx_sg,
  ]

  count                       = var.instance_count_nginx
  ami                         = var.ami_nginx
  instance_type               = var.instance_type_nginx
  subnet_id                   = keys(var.vpc_private_subnets)[count.index]
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = "true"
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile_nginx
  user_data                   = var.user_data_nginx

  root_block_device {
    encrypted   = false
    volume_type = var.volumes_type
    volume_size = var.root_disk_size_nginx
  }

  ebs_block_device {
    encrypted   = true
    device_name = var.encrypted_disk_device_name_nginx
    volume_type = var.volumes_type
    volume_size = var.encrypted_disk_size_nginx
  }
  
  tags = merge(var.common_tags, {
    Name = "nginx-${count.index+1}"
  }) 
}

# DB #
resource "aws_instance" "db" {
  depends_on = [
    aws_security_group.db_sg,
  ]

  count                       = var.instance_count_db
  ami                         = var.ami_db
  instance_type               = var.instance_type_db
  subnet_id                   = keys(var.vpc_private_subnets)[count.index]
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  associate_public_ip_address = "false"
  key_name                    = var.key_name

  tags = merge(var.common_tags, {
    Name = "db-${count.index+1}"
  })
}

# SECURITY-GROUPS
# Nginx security group 
resource "aws_security_group" "nginx_sg" {
  name   = "${var.naming_prefix}-nginx_sg"
  vpc_id = var.vpc_id
  tags = var.common_tags
}

resource "aws_security_group_rule" "nginx_allow_http_from_vpc" {
 type              = "ingress"
 description       = "HTTP access from VPC"
 from_port         = 80
 to_port           = 80
 protocol          = "tcp"
 cidr_blocks       = [var.vpc_cidr_block]
 security_group_id = aws_security_group.nginx_sg.id
}

resource "aws_security_group_rule" "nginx_allow_ssh" {
 type              = "ingress"
 description       = "SSH access from Anywhere"
 from_port         = 22
 to_port           = 22
 protocol          = "tcp"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.nginx_sg.id
}

resource "aws_security_group_rule" "nginx_allow_all_outbound" {
 type              = "egress"
 description       = "outbound internet access"
 from_port         = 0
 to_port           = 0
 protocol          = "-1"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.nginx_sg.id
}

# DB security group 
resource "aws_security_group" "db_sg" {
  name   = "${var.naming_prefix}-db_sg"
  vpc_id = var.vpc_id
  tags = var.common_tags
}

resource "aws_security_group_rule" "db_allow_http" {
 type              = "ingress"
 description       = "HTTP access through public subnets"
 from_port         = 80
 to_port           = 80
 protocol          = "tcp"
 cidr_blocks       = values(var.vpc_public_subnets)[*]
 security_group_id = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "db_allow_ssh" {
 type              = "ingress"
 description       = "SSH access from Anywhere"
 from_port         = 22
 to_port           = 22
 protocol          = "tcp"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "db_allow_all_outbound" {
 type              = "egress"
 description       = "outbound internet access"
 from_port         = 0
 to_port           = 0
 protocol          = "-1"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.db_sg.id
}