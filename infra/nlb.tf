provider "aws" {
  region = "sa-east-1"
}

# Criar um Security Group
resource "aws_security_group" "api_sg" {
  vpc_id = "YOUR_VPC_ID"  # Substitua pelo ID da sua VPC

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "api-security-group"
  }
}

# Criar um NLB
resource "aws_lb" "api_nlb" {
  name               = "api-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.api_sg.id]
  subnets            = ["YOUR_PUBLIC_SUBNET_ID_1", "YOUR_PUBLIC_SUBNET_ID_2"]  # Substitua pelos IDs das sub-redes

  enable_deletion_protection = false

  tags = {
    Name = "api-nlb"
  }
}

# Criar um Target Group para o NLB
resource "aws_lb_target_group" "api_target_group" {
  name     = "api-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = "YOUR_VPC_ID"  # Substitua pelo ID da sua VPC

  health_check {
    healthy_threshold   = 2
    interval            = 30
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

# Associar o Target Group ao NLB
resource "aws_lb_listener" "api_listener" {
  load_balancer_arn = aws_lb.api_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_target_group.arn
  }
}