resource "aws_ssm_parameter" "lobalancer_id" {
  name  = format("/%s/ecs/loadbalancer/id", var.project_name)
  value = aws_lb.main.id
  type  = "String"
}

resource "aws_ssm_parameter" "lobalancer_arn" {
  name  = format("/%s/ecs/loadbalancer/arn", var.project_name)
  value = aws_lb.main.arn
  type  = "String"
}

resource "aws_ssm_parameter" "lobalancer_dns_name" {
  name  = format("/%s/ecs/loadbalancer/dns-name", var.project_name)
  type  = "String"
  value = aws_lb.main.dns_name
}