# INSTANCES #
resource "aws_instance" "nginx" {
  depends_on = [
    aws_security_group.nginx_sg,
  ]

  count                       = var.instance_count_nginx
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id_db
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = "true"
  key_name                    = var.key_name
  iam_instance_profile        = var.nginx_iam_instance_profile
  user_data                   = var.user_data_nginx

  root_block_device {
    encrypted   = false
    volume_type = var.volumes_type
    volume_size = var.nginx_root_disk_size
  }

  ebs_block_device {
    encrypted   = true
    device_name = var.nginx_encrypted_disk_device_name
    volume_type = var.volumes_type
    volume_size = var.nginx_encrypted_disk_size
  }
  
  tags = merge(var.common_tags, {
    Name = "nginx-${count.index+1}"
  }) 
}

resource "aws_instance" "db" {
  depends_on = [
    aws_security_group.db_sg,
  ]

  count                       = var.instance_count_db
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id_db
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
  name   = "${local.name_prefix}-nginx_sg"
  vpc_id = module.my_vpc.vpc_id
  tags = local.common_tags
}

resource "aws_security_group_rule" "nginx_allow_http_from_vpc" {
 type              = "ingress"
 description       = "HTTP access from VPC"
 from_port         = 80
 to_port           = 80
 protocol          = "tcp"
 cidr_blocks       = [module.my_vpc.vpc_cidr_block]
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
  depends_on = [
    module.my_vpc,
  ]
  name   = "${local.name_prefix}-db_sg"
  vpc_id = module.my_vpc.vpc_id
  tags = local.common_tags
}

resource "aws_security_group_rule" "db_allow_http" {
 type              = "ingress"
 description       = "HTTP access through public subnets"
 from_port         = 80
 to_port           = 80
 protocol          = "tcp"
 cidr_blocks       = values(module.my_vpc.vpc_public_subnets)[*]
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