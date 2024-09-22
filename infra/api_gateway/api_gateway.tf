resource "aws_api_gateway_rest_api" "my_api_gateway" {
  name        = var.api_gateway_name
  description = "API Gateway para minha aplicação."
}

resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.my_api_gateway.root_resource_id
  path_part   = "minha-rota"
}

resource "aws_api_gateway_method" "my_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api_gateway.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "my_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  resource_id = aws_api_gateway_resource.my_resource.id
  http_method = aws_api_gateway_method.my_method.http_method

  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://example.com" # Altere para o endpoint desejado
}

resource "aws_api_gateway_deployment" "my_api_gateway" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_method.my_method
  ]
}

output "api_gateway_url" {
  value = "${aws_api_gateway_rest_api.my_api_gateway.execution_arn}/prod/minha-rota"
}