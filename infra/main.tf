module "eks" {
  source = "./eks"
}

module "nlb" {
  source = "./nlb"
  subnet_ids       = var.subnet_ids
  vpc_id           = var.vpc_id
  eks_cluster_name = module.eks.cluster_name
}

module "api_gateway" {
  source = "./api_gateway"
  nlb_dns_name = module.nlb.nlb_dns_name
}