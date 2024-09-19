provider "aws" {
  region = "sa-east-1"
}

# Criar o API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "MyApiGateway"
  description = "API Gateway for EC2 service"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "any_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.any_method.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.api_nlb.dns_name}/{proxy}" # NLB DNS

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

output "api_gateway_url" {
  value = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}