# Pull latest OS images via SSM parameters
data "aws_ssm_parameter" "ami" {
  for_each = local.os
  name     = each.value.ami_param_name
}