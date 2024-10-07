locals {
  clusters = {
    on_demand = {
      launch_template = {
        image_id                = var.node_ami
        instance_type           = var.node_instance_type
        volume_size             = var.node_volume_size
        volume_type             = var.node_volume_type
        instance_market_options = {
            market_type = null
          spot_options = {
            max_price = null
          }
        }
      }
      autoscaling_group = {
        max_size         = var.cluster_on_demand_max_size
        min_size         = var.cluster_on_demand_min_size
        desired_capacity = var.cluster_on_demand_desired_capacity
      }
      capacity_provider = {
        auto_scaling_group_provider = {
          managed_scaling = {
            maximum_scaling_step_size = 10
            minimum_scaling_step_size = 1
            target_capacity           = 90
            status                    = "ENABLED"
          }
        }
      }
    },
    spots = {
      launch_template = {
        image_id      = var.node_ami
        instance_type = var.node_instance_type
        volume_size   = var.node_volume_size
        volume_type   = var.node_volume_type
        instance_market_options = {
          market_type = "spot"
          spot_options = {
            max_price = "0.15"
          }
        }
      }
      autoscaling_group = {
        max_size         = var.cluster_spots_max_size
        min_size         = var.cluster_spots_min_size
        desired_capacity = var.cluster_spots_desired_capacity
      }
      capacity_provider = {
        auto_scaling_group_provider = {
          managed_scaling = {
            maximum_scaling_step_size = 10
            minimum_scaling_step_size = 1
            target_capacity           = 90
            status                    = "ENABLED"
          }
        }
      }
    }
  }
}

resource "aws_ecs_cluster" "main" {
  name = var.project_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = var.project_name
  }
}

resource "aws_launch_template" "main" {
  for_each      = { for k, v in local.clusters : k => v }
  name_prefix   = format("%s-%s", var.project_name, each.key)
  image_id      = each.value.launch_template.image_id
  instance_type = each.value.launch_template.instance_type
  vpc_security_group_ids = [
    aws_security_group.main.id
  ]
  update_default_version = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = each.value.launch_template.volume_size
      volume_type = each.value.launch_template.volume_type
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.main.name
  }

  instance_market_options {
    market_type = each.value.launch_template.instance_market_options.market_type
    spot_options {
        max_price = each.value.launch_template.instance_market_options.spot_options.max_price
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = format("%s-on-demand", var.project_name)
    }
  }

  user_data = base64encode(
    templatefile("${path.module}/template/user-data.tpl", {
      cluster_name = aws_ecs_cluster.main.name
    })
  )
}

resource "aws_autoscaling_group" "main" {
  for_each    = { for k, v in local.clusters : k => v }
  name_prefix = format("%s-%s", var.project_name, each.key)

  vpc_zone_identifier = [
    data.aws_ssm_parameter.private_subnet_1a.value,
    data.aws_ssm_parameter.private_subnet_1b.value,
    data.aws_ssm_parameter.private_subnet_1c.value
  ]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  max_size         = each.value.autoscaling_group.max_size
  min_size         = each.value.autoscaling_group.min_size
  desired_capacity = each.value.autoscaling_group.desired_capacity

  launch_template {
    id      = aws_launch_template.main[each.key].id
    version = aws_launch_template.main[each.key].latest_version
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = format("%s-on-demand", var.project_name)
  }

  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = true
  }
}

resource "aws_ecs_capacity_provider" "main" {
  for_each = { for k, v in local.clusters : k => v }
  name     = format("%s-%s", var.project_name, each.key)

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.main[each.key].arn
    managed_scaling {
      maximum_scaling_step_size = each.value.capacity_provider.auto_scaling_group_provider.managed_scaling.maximum_scaling_step_size
      minimum_scaling_step_size = each.value.capacity_provider.auto_scaling_group_provider.managed_scaling.minimum_scaling_step_size
      target_capacity           = each.value.capacity_provider.auto_scaling_group_provider.managed_scaling.target_capacity
      status                    = "ENABLED"
    }
  }

  tags = {
    Name = format("%s-on-demand", var.project_name)
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  for_each     = { for k, v in local.clusters : k => v }
  cluster_name = aws_ecs_cluster.main.name
  capacity_providers = [
    aws_ecs_capacity_provider.main[each.key].name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main[each.key].name
    weight            = 100
    base              = 0
  }
}