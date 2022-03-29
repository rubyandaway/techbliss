output "webserver_subnet_id" {
  value = aws_subnet.webserver_subnet.id
}

output "webserver_ami_id" {
  value = data.aws_ssm_parameter.ami-id.value
  sensitive = "true"
}