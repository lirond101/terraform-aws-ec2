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

# DB #
resource "aws_instance" "db_server" {
  depends_on = [
    aws_security_group.db_sg,
  ]

  count                       = var.instance_count_db
  ami                         = var.ami_db
  instance_type               = var.instance_type
  subnet_id                   = var.vpc_private_subnets[count.index % length(var.vpc_private_subnets)]
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile_db

  root_block_device {
    encrypted   = false
    volume_type = var.volumes_type
    volume_size = var.root_disk_size_db
  }

  ebs_block_device {
    encrypted   = true
    device_name = var.encrypted_disk_device_name
    volume_type = var.volumes_type
    volume_size = var.encrypted_disk_size_db
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-db-${count.index+1}",
    Type = "db"
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

# DB security group 
resource "aws_security_group" "db_sg" {
  name   = "${var.name_prefix}-db_sg"
  vpc_id = var.vpc_id
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-db_sg"
  })
}

resource "aws_security_group_rule" "db_allow_postgres_from_vpc" {
 type              = "ingress"
 description       = "Allow all access from VPC"
 from_port         = 5432
 to_port           = 5432
 protocol          = "tcp"
 cidr_blocks       = [var.vpc_cidr_block]
 security_group_id = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "db_allow_ssh" {
 type              = "ingress"
 description       = "SSH access from VPC"
 from_port         = 22
 to_port           = 22
 protocol          = "tcp"
 cidr_blocks       = [var.vpc_cidr_block]
 security_group_id = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "consul_allow_8500" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8500
  to_port                  = 8500
  cidr_blocks              = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description              = "Allow HTTP traffic from Consul Client."
  security_group_id        = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "consul_allow_client_8600_udp" {
  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8600
  to_port                  = 8600
  cidr_blocks              = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description              = "Allow UDP traffic for DNS queries."
  security_group_id        = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "consul_allow_client_8600_tcp" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8600
  to_port                  = 8600
  cidr_blocks              = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description              = "Allow TCP traffic for DNS queries."
  security_group_id        = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "consul_server_allow_client_8301_tcp" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8301
  to_port                  = 8301
  cidr_blocks              = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description              = "Allow LAN gossip traffic from Consul Client to Server.  For managing cluster membership for distributed health check of the agents."
  security_group_id        = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "consul_server_allow_client_8301_udp" {
  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8301
  to_port                  = 8301
  cidr_blocks              = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description              = "Allow LAN gossip traffic from Consul Client to Server.  For managing cluster membership for distributed health check of the agents."
  security_group_id        = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "consul_server_allow_client_8302_tcp" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8302
  to_port                  = 8302
  cidr_blocks              = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description              = "Allow WAN gossip traffic from Consul Client to Server.  For managing cluster membership for distributed health check of the agents."
  security_group_id        = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "consul_server_allow_client_8302_udp" {
  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8302
  to_port                  = 8302
  cidr_blocks              = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description              = "Allow WAN gossip traffic from Consul Client to Server.  For managing cluster membership for distributed health check of the agents."
  security_group_id        = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "consul_server_allow_8300" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8300
  to_port                  = 8300
  cidr_blocks              = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description              = "Allow RPC traffic from Consul Client to Server and Server to Server.  For client and server agents to send and receive data stored in Consul."
  security_group_id        = aws_security_group.db_sg.id
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