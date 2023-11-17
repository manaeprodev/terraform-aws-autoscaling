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
