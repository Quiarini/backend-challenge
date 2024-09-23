module "api_gateway" {
  source           = "./api_gateway"
  api_gateway_name = "jwt-validator-api"
}

module "eks" {
  source      = "./eks"
  eks_role_arn = module.iam.eks_role_arn  # Verifique se o output está correto
}

module "nlb" {
  source = "./nlb"
}

module "iam" {
  source = "./iam"
}