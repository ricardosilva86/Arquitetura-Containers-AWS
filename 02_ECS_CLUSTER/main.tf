resource "aws_security_group" "lb" {
  name   = format("%s-loadbalancer", var.project_name)
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_security_group_rule" "ingress" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

resource "aws_security_group" "main" {
  name   = format("%s-vpc-sg", var.project_name)
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_security_group_rule" "subnet_ranges" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow all traffic within the VPC"
  security_group_id = aws_security_group.main.id
  type              = "ingress"
  cidr_blocks = [
    "10.0.0.0/16",
  ]
}

resource "aws_lb" "main" {
  name               = format("%s-ingress", var.project_name)
  internal           = var.loadbalancer_internal
  load_balancer_type = var.loadbalancer_type
  security_groups = [
    aws_security_group.lb.id
  ]
  subnets = [
    data.aws_ssm_parameter.public_subnet_1a.value,
    data.aws_ssm_parameter.public_subnet_1b.value,
    data.aws_ssm_parameter.public_subnet_1c.value
  ]
  enable_cross_zone_load_balancing = false
  enable_deletion_protection       = false
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "ACA LinuxTips"
      status_code  = "200"
    }
  }
}