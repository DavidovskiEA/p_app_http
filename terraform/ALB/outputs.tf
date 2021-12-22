output "availability_zones0" {
  value = data.aws_availability_zones.available.names[0]
}
output "availability_zones1" {
  value = data.aws_availability_zones.available.names[1]
}
#output "aws_lb" {
#  value = data.aws_lb.test.id
#}
output "aws_lb" {
  value = aws_lb.test.name
  description = "lb_test"
}
output "aws_autoscaling_group" {
  value = aws_autoscaling_group.webserver.name
}
output "aws_lb_target_group" {
  value = aws_lb_target_group.test.name
}
output "aws_lb_listener_certificate" {
  value = aws_lb_listener_certificate.test.certificate_arn
}
output "aws_region" {
  value = data.aws_region.current.name
}
output "aws_region_description" {
  value = data.aws_region.current.description
}
