variable "aws_region" {
  description = "A região AWS onde a infraestrutura será criada."
  default     = "sa-east-1"
}

variable "api_gateway_name" {
  description = "Nome do API Gateway."
  default     = "jwt-validator"
}

variable "eks_cluster_name" {
  description = "Nome do cluster EKS."
  default     = "jwt-validator"
}

variable "nlb_name" {
  description = "Nome do Network Load Balancer."
  default     = "MyNLB"
}


variable "vpc_id" {
  description = "ID da VPC"
  default     = "vpc-0230ad20389106f29"
}

variable "vpc_id" {
  description = "ID da VPC"
  default     = ["subnet-03493ba700fceaff4","subnet-039d5bb4e357b5d8e"]
}