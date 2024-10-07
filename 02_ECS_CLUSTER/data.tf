data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id
}

data "aws_ssm_parameter" "private_subnet_1a" {
  name = var.private_subnet_1a
}

data "aws_ssm_parameter" "private_subnet_1b" {
  name = var.private_subnet_1b
}

data "aws_ssm_parameter" "private_subnet_1c" {
  name = var.private_subnet_1c
}

data "aws_ssm_parameter" "public_subnet_1a" {
  name = var.public_subnet_1a
}

data "aws_ssm_parameter" "public_subnet_1b" {
  name = var.public_subnet_1b
}

data "aws_ssm_parameter" "public_subnet_1c" {
  name = var.public_subnet_1c
}

data "aws_ssm_parameter" "database_subnet_1a" {
  name = var.database_subnet_1a
}

data "aws_ssm_parameter" "database_subnet_1b" {
  name = var.database_subnet_1b
}

data "aws_ssm_parameter" "database_subnet_1c" {
  name = var.database_subnet_1c
}