resource "aws_lb" "nlb" {
  name               = "my-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.nlb_sg.id]
  subnet_mapping {
    subnet_id = var.subnet_ids[0]
  }
}

resource "aws_security_group" "nlb_sg" {
  name        = "nlb_security_group"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Ajuste conforme necessário para IPs específicos
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # Permitir todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]  # Ajuste conforme necessário
  }
}

output "nlb_dns_name" {
  value = aws_lb.nlb.dns_name
}

resource "aws_lb_target_group" "app_target_group" {
  name     = "java-app-target-group"
  port     = 80   # Porta em que sua aplicação Java está escutando
  protocol = "TCP"  # Use "HTTP" se você quiser fazer health checks HTTP

  vpc_id = var.vpc_id

}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80  # Porta do NLB
  protocol          = "TCP"  # Use "HTTP" se necessário

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}