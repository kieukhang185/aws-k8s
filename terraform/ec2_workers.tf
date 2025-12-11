locals {
  wk_user_data = templatefile("${path.module}/user_data/worker.sh.tmpl", {
    AWS_REGION              = var.region
    SSM_JOIN_PARAMETER_NAME = var.ssm_join_parameter_name
  })
}

resource "aws_launch_template" "workers" {
  name_prefix   = "${var.project}-wk-"
  image_id      = data.aws_ami.ubuntu_jammy.id
  instance_type = var.instance_type_wk

  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }

  network_interfaces {
    security_groups             = [aws_security_group.cluster.id]
    subnet_id                   = aws_subnet.private_a.id
    associate_public_ip_address = false
  }

  key_name  = var.key_pair_name != "" ? var.key_pair_name : null
  # user_data = base64encode(local.wk_user_data)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project}-wk"
      Project = var.project
      Role    = "worker"
    }
  }
}

resource "aws_autoscaling_group" "workers" {
  name                = "${var.project}-workers"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  launch_template {
    id      = aws_launch_template.workers.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-wk"
    propagate_at_launch = true
  }
}
