variable "aws_region" {
  description = "A região AWS onde a infraestrutura será criada."
  default     = "sa-east-1"
}

variable "api_gateway_name" {
  description = "Nome do API Gateway."
  default     = "jwt-validator-api"
}

variable "eks_cluster_name" {
  description = "Nome do cluster EKS."
  default     = "jwt-validator-cluster"
}

variable "nlb_name" {
  description = "Nome do Network Load Balancer."
  default     = "jwt-validator-nlb"
}


variable "vpc_id" {
  description = "ID da VPC"
  default     = ""
}

variable "vpc_id" {
  description = "ID da VPC"
  default     = []
}