# Launch templates for Linux and Windows
resource "aws_launch_template" "runner" {
  for_each = local.os

  name_prefix   = "gha-${each.key}-"
  image_id      = data.aws_ssm_parameter.ami[each.key].value
  instance_type = each.value.instance_type
 
  iam_instance_profile {
    name = aws_iam_instance_profile.runner.name
  }

  vpc_security_group_ids = [var.runner_security_grp]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # User data script (injected with templatefile)
  user_data = base64encode(
    templatefile(each.value.user_data_tpl, {
      org        = var.org
      ssm_name   = var.runner_token_parameter_name
      runner_ver = var.runner_version
      labels     = each.value.label_string
      region     = var.region
    })
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      "Name" = "gha-runner-${each.key}"
      "OS"   = each.key
    })
  }
}

# Auto Scaling Groups
resource "aws_autoscaling_group" "runner" {
  for_each               = local.os
  name                   = "gha-${each.key}-asg"
  max_size               = var.asg_max_size
  min_size               = 0
  desired_capacity       = lookup(local.desired, each.key, 0)
  vpc_zone_identifier    = var.subnet_ids
  health_check_type      = "EC2"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.runner[each.key].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "gha-runner-${each.key}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}






