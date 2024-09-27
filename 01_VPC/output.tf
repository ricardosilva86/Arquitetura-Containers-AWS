output "vpc_id" {
  value = aws_ssm_parameter.vpc.value
  sensitive = true
}