resource "aws_security_group" "as_sg" {
  name        = "as_sg"
  vpc_id      = module.discovery.vpc_id

  tags = {
    Name = "as_sg"
  }
}

resource "aws_security_group_rule" "sgr-ingress-as" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.as_sg.id
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sgr-egress-as" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.as_sg.id}"
}

resource "aws_launch_template" "template" {
  name = "template_resto"

  image_id = module.discovery.images_id[0]

  vpc_security_group_ids = [aws_security_group.as_sg.id]

  instance_type = "t2.micro"

  key_name = "ma-vraie-clef"
}

resource "aws_autoscaling_group" "as_group" {
  max_size = 2
  min_size = 1
  desired_capacity = 1
  vpc_zone_identifier = module.discovery.public_subnets
  target_group_arns = [aws_lb_target_group.lb-tg.arn]

  launch_template {
    id = aws_launch_template.template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "policy1" {
  name                   = "policy1-test"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.as_group.name
}

resource "aws_cloudwatch_metric_alarm" "GreaterThanOrEqualTo80" {
  alarm_name                = "GreaterThanOrEqualTo80"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 15

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as_group.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.policy1.arn]
}

resource "aws_autoscaling_policy" "policy2" {
  name                   = "policy2-test"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.as_group.name
}

resource "aws_cloudwatch_metric_alarm" "LessThanOrEqualTo80" {
  alarm_name                = "LessThanOrEqualTo80"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 10

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as_group.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.policy2.arn]
}
