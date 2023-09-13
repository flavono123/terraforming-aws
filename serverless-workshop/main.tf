terraform {
  required_version = "~> 1.5.7"

  required_providers {
    aws = "~> 5.16.2"
  }
}

locals {
  apigateway = {
    api_name   = "delivery-api"
    stage_name = "dev"
    route_key  = "POST /order"
  }
}

# cf2tf <(wget -qO- https://static.us-east-1.prod.workshops.aws/public/ebdd2af6-e669-4dd3-99bd-c9de7921832e/assets/serverless-lab-cf.yaml)
# wrap assume_role_policy in jsonencode
data "aws_partition" "current" {}

resource "aws_iam_role" "apigwdeliveryorderrole_f75_cf62_c" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })

  description = "A role for API Gateway to access SQS and EventBridge"
  managed_policy_arns = [
    join("", ["arn:", data.aws_partition.current.partition, ":iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"]),
    join("", ["arn:", data.aws_partition.current.partition, ":iam::aws:policy/AmazonSQSFullAccess"]),
    join("", ["arn:", data.aws_partition.current.partition, ":iam::aws:policy/AmazonEventBridgeFullAccess"])
  ]
  name = "apigw-delivery-order-role"
}

## API Gateway

### API
resource "aws_apigatewayv2_api" "delivery_api" {
  name          = local.apigateway.api_name
  protocol_type = "HTTP"
}

### Deploy/Stages
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.delivery_api.id
  name        = "$default"
  auto_deploy = true
}
resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.delivery_api.id
  name        = local.apigateway.stage_name
  auto_deploy = true
}

### Develop/Routes

resource "aws_apigatewayv2_route" "post_order" {
  api_id    = aws_apigatewayv2_api.delivery_api.id
  route_key = local.apigateway.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_order_function.id}"
}

### Devlop/Integrations
resource "aws_apigatewayv2_integration" "lambda_order_function" {
  api_id           = aws_apigatewayv2_api.delivery_api.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = module.order_function.lambda_function_invoke_arn
}

## Lambda
module "order_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "OrderFunction"
  runtime       = "nodejs16.x"
  architectures = ["arm64"]
  handler       = "index.handler"

  source_path = "src/index.js"

  create_current_version_allowed_triggers = false

  allowed_triggers = {
    APIGatewayDelivery = {
      service    = "apigateway"
      source_arn = "${aws_apigatewayv2_api.delivery_api.execution_arn}/*/*"
    }
  }
}

## SQS
module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 4.0.2"

  name = "OrderQueue"
}
