output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint  # Adicione isso no módulo EKS
}

output "nlb_dns_name" {
  value = module.nlb.nlb_dns_name
}

output "api_gateway_url" {
  value = module.api_gateway.api_gateway_url
}