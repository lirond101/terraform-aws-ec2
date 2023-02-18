output "aws_nginx_public_dns" {
  value = aws_instance.nginx.*.private_ip
}

output "aws_db_public_dns" {
  value = aws_instance.db.*.private_ip
}