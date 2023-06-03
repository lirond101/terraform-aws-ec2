output "bastion_servers" {
  value = aws_instance.bastion.*.public_ip
}

output "db_servers" {
  value = aws_instance.db_server.*.private_ip
}

output "aws_db_ids" {
  value = aws_instance.db_server.*.id
}