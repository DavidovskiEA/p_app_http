variable "region" {
  default = "us-east-2"
}

variable "availability_zones" {
  default = ["us-east-2", "us-east-2", "us-east-2"]
}

provider "aws" {
  region = "us-east-2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

#------------------------------------------
resource "aws_vpc" "infrustruct" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "infrustruct"
  }
}
#------------------------------------------
resource "aws_security_group" "webserver1" {
  name        = "webserver sec group"

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
#------------------------------------------
resource "aws_internet_gateway" "infrustruct_gw" {
  vpc_id = aws_vpc.infrustruct.id

  tags = {
    Name = "infrustruct_gateway"
  }
}
#------------------------------------------
resource "aws_route_table" "infrustruct_route" {
  vpc_id = aws_vpc.infrustruct.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.infrustruct_gw.id
  }

  tags = {
    Name = "infrustruct_route_table"
  }
}
#------------------------------------------
resource "aws_subnet" "public_subnet" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = aws_vpc.infrustruct.id
  cidr_block = "192.168.${1+count.index}.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
}

resource "aws_instance" "infr_ec2_1" {
  count                  = length(data.availability_zones)
  ami                    = "ami-0fb653ca2d3203ac1"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webserver1.id]
  key_name               = "datatesting"
  subnet_id              = aws_subnet.my_subnet[count.index].id

  #availability_zone      = [aws_availability_zones.available.names[1]]

  tags = {
    Name = "infr_ec2_1"
  }
}

output "availability_zones0" {
  value = data.aws_availability_zones.available.names[0]
}
output "availability_zones1" {
  value = data.aws_availability_zones.available.names[1]
}
output "availability_zones2" {
  value = data.aws_availability_zones.available.names[2]
}
