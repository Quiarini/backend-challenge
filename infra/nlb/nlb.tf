resource "aws_lb" "nlb" {
  name               = "jwt-validator-nlb"
  internal           = false
  load_balancer_type = "network"
  enable_deletion_protection = false
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "nlb_target_group" {
  name     = "jwt-validator-nlb-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
  }
}

output "nlb_dns_name" {
  value = aws_lb.nlb.dns_name
}