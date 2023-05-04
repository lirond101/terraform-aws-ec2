output "bastion_servers" {
  value = aws_instance.bastion.*.public_ip
}

output "consul_servers" {
  value = aws_instance.consul_server.*.private_ip
}

output "aws_consul_ids" {
  value = aws_instance.consul_server.*.id
}