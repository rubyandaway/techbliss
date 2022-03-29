#output "PrivateIP" {
#  value = aws_instance.my-instance.private_ip
#}

output "PublicIP" {
  value = aws_instance.my-instance.public_dns
}

output "DNS" {
  value = aws_instance.my-instance.public_dns
}