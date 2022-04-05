output "module_public_subnet_1" {
  value = aws_subnet.module_public_subnet_1.id
}

output "module_public_subnet_2" {
  value = aws_subnet.module_public_subnet_2.id
}

output "module_vpc_id" {
  value = aws_vpc.main_vpc.id
}