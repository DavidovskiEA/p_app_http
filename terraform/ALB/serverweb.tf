provider "aws" {
  region = "us-east-2"
}
#------------------------------------------
#------------------------------------------
data "aws_availability_zones" "available" {}

resource "aws_security_group" "webserver" {
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
resource "aws_launch_configuration" "webserver" {
  //  name            = "WebServer-Highly-Available-LC"
  name_prefix     = "WebServer-Highly-Available-LC-"
  image_id        = "ami-00399ec92321828f5"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.webserver.id]
  user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}
#------------------------------------------
resource "aws_autoscaling_group" "webserver" {
  name                 = "ASG-${aws_launch_configuration.webserver.name}"
  launch_configuration = aws_launch_configuration.webserver.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers       = [aws_lb.webserver.name]

  dynamic "tag" {
    for_each = {
      Name   = "WebServer in ASG"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
#------------------------------------------
resource "aws_lb" "webserver" {
  name               = "WebServer-HA-ELB"
#  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.webserver.id]
  load_balancer_type = "application"
  dns_name = "datatesting.click"

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  listener {
    lb_port           = 443
    lb_protocol       = "https"
    instance_port     = 80
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:acm:us-east-2:412506339427:certificate/f05172f0-18e9-4a69-81b7-57df60abff55"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "WebServer-Highly-Available-ELB"
    Environment = "production"
  }
}
#------------------------------------------
#resource "aws_route53_record" "www" {
#  zone_id = aws_route53_zone.primary.zone_id
#  name    = "example.com"
#  type    = "A"
#
#  alias {
#    name                   = aws_lb.main.dns_name
#    zone_id                = aws_lb.main.zone_id
#    evaluate_target_health = true
#  }
#}


resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

output "web_loadbalancer_url" {
  value = aws_lb.webserver.dns_name
}
