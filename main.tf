# BASTION #
resource "aws_instance" "bastion" {
  depends_on = [
    aws_security_group.bastion_sg,
  ]

  count                       = var.instance_count_bastion
  ami                         = var.ami_bastion
  instance_type               = var.instance_type
  subnet_id                   = var.vpc_public_subnets[count.index]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = "true"

  root_block_device {
    encrypted   = false
    volume_type = var.volumes_type
    volume_size = var.root_disk_size_bastion
  }

  ebs_block_device {
    encrypted   = true
    device_name = var.encrypted_disk_device_name
    volume_type = var.volumes_type
    volume_size = var.encrypted_disk_size_bastion
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-bastion-${count.index+1}"
  }) 
}

# CONSUL #
resource "aws_instance" "consul_server" {
  depends_on = [
    aws_security_group.consul_sg,
  ]

  count                       = var.instance_count_consul
  ami                         = var.ami_consul
  instance_type               = var.instance_type
  subnet_id                   = var.vpc_private_subnets[count.index % length(var.vpc_private_subnets)]
  vpc_security_group_ids      = [aws_security_group.consul_sg.id]
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile_consul
  user_data                   = var.user_data_consul
  # user_data                   = file("${path.module}/scripts/consul-server.sh")

  root_block_device {
    encrypted   = false
    volume_type = var.volumes_type
    volume_size = var.root_disk_size_consul
  }

  ebs_block_device {
    encrypted   = true
    device_name = var.encrypted_disk_device_name
    volume_type = var.volumes_type
    volume_size = var.encrypted_disk_size_consul
  }
  
  tags = merge(var.common_tags, {
    Name = "opsschool-server"
    consul_server = "true"
  }) 
}

# SECURITY-GROUPS
# BASTION security group 
resource "aws_security_group" "bastion_sg" {
  name   = "${var.name_prefix}-bastion_sg"
  vpc_id = var.vpc_id
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-bastion_sg"
  })
}

resource "aws_security_group_rule" "bastion_allow_ssh" {
 type              = "ingress"
 description       = "SSH access from specific addresses"
 from_port         = 22
 to_port           = 22
 protocol          = "tcp"
 cidr_blocks       = var.bastion_allowed_cidr_blocks
 security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_security_group_rule" "bastion_allow_all_outbound" {
 type              = "egress"
 description       = "outbound internet access"
 from_port         = 0
 to_port           = 0
 protocol          = "-1"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.bastion_sg.id
}

# Consul security group 
resource "aws_security_group" "consul_sg" {
  name   = "${var.name_prefix}-consul_sg"
  vpc_id = var.vpc_id
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-consul_sg"
  })
}

resource "aws_security_group_rule" "consul_allow_all_from_vpc" {
 type              = "ingress"
 description       = "Allow all access from VPC"
 from_port         = 0
 to_port           = 0
 protocol          = "-1"
 cidr_blocks       = [var.vpc_cidr_block]
 security_group_id = aws_security_group.consul_sg.id
}

resource "aws_security_group_rule" "consul_allow_ssh" {
 type              = "ingress"
 description       = "SSH access from VPC"
 from_port         = 22
 to_port           = 22
 protocol          = "tcp"
 cidr_blocks       = [var.vpc_cidr_block]
 security_group_id = aws_security_group.consul_sg.id
}

resource "aws_security_group_rule" "consul_allow_all_outbound" {
 type              = "egress"
 description       = "outbound internet access"
 from_port         = 0
 to_port           = 0
 protocol          = "-1"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.consul_sg.id
}