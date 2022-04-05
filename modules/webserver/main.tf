resource "aws_instance" "webserver_machine" {
  ami = var.ami
  instance_type = var.instance_type
  user_data = "${file("modules/webserver/scripts/Apache-server.sh")}"
  subnet_id = ""
  tags = {
    Name = "webserver_instance"
  }
}


