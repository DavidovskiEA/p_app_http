provider "aws" {
  region = "us-east-2"
}
#------------------------------------------
data "aws_availability_zones" "available" {
    state = "available"
}
data "aws_region" "current" {}
#------------------------------------------
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
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webserver.id]
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  enable_cross_zone_load_balancing = true
}
resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.test.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-2:412506339427:certificate/f05172f0-18e9-4a69-81b7-57df60abff55"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_lb_listener_certificate" "test" {
  listener_arn    = aws_lb_listener.test.arn
  certificate_arn = "arn:aws:acm:us-east-2:412506339427:certificate/f05172f0-18e9-4a69-81b7-57df60abff55"
}

resource "aws_lb_listener" "test1" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-9dea61f6"

  depends_on = [
  aws_lb.test
]
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
  target_group_arns    = [aws_lb_target_group.test.arn]

  dynamic "tag" {
    for_each = {
      Name   = "WebServer in ASG"
      Owner  = "YD"
      TAGKEY = "TAGVALUE"
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
  depends_on = [aws_lb.test]
}

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
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}
