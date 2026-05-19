#Auto Scaling Group

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = 2
  max_size         = 4
  min_size         = 2

  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  target_group_arns = [aws_lb_target_group.app_tg.arn] #conncet EC2 au target group

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "app-asg-instance"
    propagate_at_launch = true
  }
}