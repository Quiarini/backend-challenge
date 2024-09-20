# EKS
module "eks" {
  source = "./eks.tf"
}

# API Gateway
module "api_gateway" {
  source = "./api_gateway.tf"
}

# Network Load Balancer
module "nlb" {
  source = "./nlb.tf"
}