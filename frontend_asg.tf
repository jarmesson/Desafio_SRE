data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "frontend" {
  name_prefix   = "frontend-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type_frontend

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y
systemctl enable nginx
systemctl start nginx

# HTML
echo "<html>
<head><title>Desafio SRE</title></head>
<body style='font-family: Arial; text-align: center; margin-top: 50px;'>
<h1>Ambiente funcionando corretamente.</h1>
</body>
</html>" > /usr/share/nginx/html/index.html

EOF
  )
}

resource "aws_lb" "alb" {
  name               = "alb-example"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_autoscaling_group" "frontend_asg" {
  name                = "frontend-asg"
  max_size            = 4
  min_size            = 1
  desired_capacity    = var.desired_capacity_frontend
  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.frontend_tg.arn
  ]

  depends_on = [aws_lb_listener.http]
}

resource "aws_autoscaling_policy" "frontend_scale_out" {
  name                   = "frontend-scale-out"
  autoscaling_group_name = aws_autoscaling_group.frontend_asg.name
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
  }
}

resource "aws_cloudwatch_metric_alarm" "frontend_high_requests" {
  alarm_name          = "frontend-high-requests"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 100
  evaluation_periods  = 2
  period              = 60
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Average"

  alarm_actions = [
    aws_autoscaling_policy.frontend_scale_out.arn
  ]

  dimensions = {
    TargetGroup  = aws_lb_target_group.frontend_tg.arn_suffix
    LoadBalancer = aws_lb.alb.arn_suffix
  }
}

resource "aws_autoscaling_policy" "frontend_scale_in" {
  name                   = "frontend-scale-in"
  autoscaling_group_name = aws_autoscaling_group.frontend_asg.name
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"

  step_adjustment {
    scaling_adjustment           = -1
    metric_interval_upper_bound  = 0
  }
}

resource "aws_cloudwatch_metric_alarm" "frontend_low_requests" {
  alarm_name          = "frontend-low-requests"
  comparison_operator = "LessThanThreshold"
  threshold           = 20
  evaluation_periods  = 2
  period              = 60
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Average"

  alarm_actions = [
    aws_autoscaling_policy.frontend_scale_in.arn
  ]

  dimensions = {
    TargetGroup  = aws_lb_target_group.frontend_tg.arn_suffix
    LoadBalancer = aws_lb.alb.arn_suffix
  }
}
