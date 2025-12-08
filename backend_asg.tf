resource "aws_launch_template" "backend_lt" {
  name          = "backend-launch-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type_backend

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y python3
echo "Backend rodando." > /home/ec2-user/index.html
nohup python3 -m http.server 8080 &
EOF
  )

  vpc_security_group_ids = [
    aws_security_group.backend_sg.id
  ]
}

resource "aws_lb" "backend_alb" {
  name               = "backend-internal-alb"
  internal           = true                  
  load_balancer_type = "application"
  subnets            = aws_subnet.private[*].id
  security_groups    = [aws_security_group.alb_internal_sg.id]   # AJUSTADO

  tags = {
    Name = "backend-alb"
  }
}

resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    port                = "8080"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }

  tags = {
    Name = "backend-tg"
  }
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  name                = "backend-asg"
  max_size            = 3
  min_size            = 2
  desired_capacity    = 2
  vpc_zone_identifier = aws_subnet.private[*].id

  health_check_type         = "EC2"
  health_check_grace_period = 30

  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.backend_tg.arn
  ]

  depends_on = [aws_lb_listener.backend_listener]
}

resource "aws_autoscaling_policy" "backend_scale_out" {
  name                   = "backend-scale-out"
  autoscaling_group_name = aws_autoscaling_group.backend_asg.name
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_high_requests" {
  alarm_name          = "backend-high-requests"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 100
  evaluation_periods  = 2
  period              = 60
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Average"

  alarm_actions = [
    aws_autoscaling_policy.backend_scale_out.arn
  ]

  dimensions = {
    TargetGroup  = aws_lb_target_group.backend_tg.arn_suffix
    LoadBalancer = aws_lb.backend_alb.arn_suffix
  }
}

resource "aws_autoscaling_policy" "backend_scale_in" {
  name                   = "backend-scale-in"
  autoscaling_group_name = aws_autoscaling_group.backend_asg.name
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"

  step_adjustment {
    scaling_adjustment           = -1
    metric_interval_upper_bound  = 0
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_low_requests" {
  alarm_name          = "backend-low-requests"
  comparison_operator = "LessThanThreshold"
  threshold           = 20
  evaluation_periods  = 2
  period              = 60
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Average"

  alarm_actions = [
    aws_autoscaling_policy.backend_scale_in.arn
  ]

  dimensions = {
    TargetGroup  = aws_lb_target_group.backend_tg.arn_suffix
    LoadBalancer = aws_lb.backend_alb.arn_suffix
  }
}
