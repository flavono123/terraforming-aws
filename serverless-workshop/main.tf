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
