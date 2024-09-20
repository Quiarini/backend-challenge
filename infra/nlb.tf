resource "aws_lb" "my_nlb" {
  name               = var.nlb_name
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.my_nlb_sg.id]
  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true

  tags = {
    Name = var.nlb_name
  }
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_security_group" "my_nlb_sg" {
  name        = "nlb_sg"
  description = "Security group for NLB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}