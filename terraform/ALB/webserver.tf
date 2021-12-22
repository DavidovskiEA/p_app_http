provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "webserver" {
  ami = "ami-00399ec92321828f5"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webserver.id]
  user_data = file("user_data.sh")

  tags = {
    Name = "web server by terraform"
  }

  lifecycle{
    create_before_destroy = true
  }
}

resource "aws_eip" "my_static_ip" {
  instance = aws_instance.webserver.id
}


resource "aws_security_group" "webserver" {
  name        = "webserver sec group"
  description = "webserver sec group"


  dynamic "ingress" {
    for_each = ["22","80","443"]
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web server by terraform"
  }
}

output "webserver_instance_id" {
  value = aws_instance.webserver.id
}

output "webserver_instance_public_ip" {
  value = aws_eip.my_static_ip.public_ip
}

output "webserver_sg_id" {
  value = aws_security_group.webserver.id
}

output "webserver_sg_arn" {
  value = aws_security_group.webserver.arn
}
