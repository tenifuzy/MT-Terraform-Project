output "vpc_id" {
  value = aws_vpc.MTVPC.id
}

output "public_subnet_id" {
  value = aws_subnet.Public-Subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.Private-Subnet.id
}

output "webserver_id" {
  value = aws_instance.webserver.id
}

output "dbserver_id" {
  value = aws_instance.db-server.id
}