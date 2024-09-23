resource "aws_iam_role" "api_gateway_logs_role" {
  name = "APIGatewayLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = ["apigateway.amazonaws.com","lambda.amazonaws.com"]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "api_gateway_logs_policy" {
  name        = "APIGatewayLogsPolicy"
  description = "Policy to allow API Gateway to log to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_logs_policy_attachment" {
  role       = aws_iam_role.api_gateway_logs_role.name
  policy_arn = aws_iam_policy.api_gateway_logs_policy.arn
}

resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_logs_role.arn

  depends_on = [
    aws_iam_role.api_gateway_logs_role,
    aws_iam_policy.api_gateway_logs_policy,
    aws_iam_role_policy_attachment.api_gateway_logs_policy_attachment
  ]
}

resource "aws_api_gateway_rest_api" "my_api_gateway" {
  name        = var.api_gateway_name
  description = "API Gateway para minha aplicação."
  endpoint_configuration {
    types = ["REGIONAL"]
  }
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

# Criar o VPC Link para o API Gateway
resource "aws_api_gateway_vpc_link" "my_vpc_link" {
  name = "my-vpc-link"
  target_arns = [
    "arn:aws:elasticloadbalancing:sa-east-1:155314306528:loadbalancer/net/my-nlb/873781d3a6e5989c" # Substitua com o arn do seu NLB
  ]
}

resource "aws_api_gateway_integration" "my_integration" {
rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  resource_id = aws_api_gateway_resource.my_resource.id
  http_method = aws_api_gateway_method.my_method.http_method

  integration_http_method = "POST"
  type                    = "HTTP"
  uri                     = "http://my-nlb-873781d3a6e5989c.elb.sa-east-1.amazonaws.com" # DNS do NLB

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.my_vpc_link.id
}

resource "aws_api_gateway_deployment" "my_api_gateway" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_method.my_method
  ]
}

resource "aws_cloudwatch_log_group" "my_api_gateway_log_group" {
  name = "/aws/api_gateway/jwt-validator_log_group"
}

resource "aws_api_gateway_stage" "my_api_gateway_stage" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  stage_name  = "prod"

  deployment_id = aws_api_gateway_deployment.my_api_gateway.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.my_api_gateway_log_group.arn
    format = "$context.identity.sourceIp - $context.requestId - $context.httpMethod - $context.path - $context.status"
  }

  depends_on = [
    aws_api_gateway_account.api_gateway_account
  ]
}

resource "aws_api_gateway_method_settings" "my_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  stage_name  = aws_api_gateway_stage.my_api_gateway_stage.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "INFO"
    metrics_enabled    = true
    data_trace_enabled = true
  }
}


output "api_gateway_url" {
  value = "${aws_api_gateway_rest_api.my_api_gateway.execution_arn}/prod/minha-rota"
}