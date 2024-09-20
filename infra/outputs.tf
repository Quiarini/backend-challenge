output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.my_api_gateway.invoke_url}/${aws_api_gateway_stage.my_stage.stage_name}"
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.my_eks.endpoint
}

output "nlb_dns_name" {
  value = aws_lb.my_nlb.dns_name
}