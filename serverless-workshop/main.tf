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
  lambda_name          = "OrderFunction"
  sqs_name             = "OrderQueue"
  dlq_name             = "OrderDLQ"
  eventbridge_bus_name = "OrderEventBus"
  sns = {
    topic_name   = "PickupOrderTopic"
    display_name = "PickupOrder"
    subscription = {
      email = "flavono123@gmail.com" # pull up as variable if want to be redacted
    }
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

## Devlop/Integrations

resource "aws_apigatewayv2_integration" "lambda_order_function" {
  api_id          = aws_apigatewayv2_api.delivery_api.id
  credentials_arn = aws_iam_role.apigwdeliveryorderrole_f75_cf62_c.arn

  integration_type    = "AWS_PROXY"
  integration_subtype = "EventBridge-PutEvents"

  request_parameters = {
    EventBusName = module.order_event.eventbridge_bus_name,
    Source       = "com.mycompany.order",
    DetailType   = "OrderType",
    Detail       = "$request.body.messageBody",
  }
}


## Lambda
module "order_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 6.0.0"

  function_name = local.lambda_name
  runtime       = "nodejs16.x"
  architectures = ["arm64"]
  handler       = "index.handler"

  source_path = "src/index.js"

  create_current_version_allowed_triggers = false

  event_source_mapping = {
    sqs = {
      event_source_arn = module.order_queue.queue_arn
    }
  }

  attach_policy = true
  policy        = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

## SQS
module "order_queue" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 4.0.2"

  name = local.sqs_name

  # Dead-letter queue
  create_dlq = true
  dlq_name   = local.dlq_name
  redrive_policy = {
    maxReceiveCount = 1
  }
}

## EventBridge

module "order_event" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "~> 2.3.0"

  create_role = true
  bus_name    = local.eventbridge_bus_name

  append_rule_postfix = false

  attach_sqs_policy = true
  sqs_target_arns = [
    module.order_queue.queue_arn
  ]

  attach_sns_policy = true
  sns_target_arns = [
    module.pickup_order_topic.topic_arn
  ]

  rules = {
    DeliveryOrderRule = {
      event_pattern = jsonencode({
        source = ["com.mycompany.order"],
        detail = {
          orderType = ["order-delivery"]
        }
      })
    }
    PickupOrderRule = {
      event_pattern = jsonencode({
        source = ["com.mycompany.order"],
        detail = {
          orderType = ["order-pickup"]
        }
      })
    }
  }

  targets = {
    DeliveryOrderRule = [
      {
        name = "order"
        arn  = aws_cloudwatch_log_group.event_delivery_order.arn
      },
      {
        name = "OrderQueue"
        arn  = module.order_queue.queue_arn
      }
    ]
    PickupOrderRule = [
      {
        name = "PickupOrderTopic"
        arn  = module.pickup_order_topic.topic_arn
      }
    ]
  }
}

resource "aws_cloudwatch_log_group" "event_delivery_order" {
  name = "/aws/events/food/order"
}

## SNS

module "pickup_order_topic" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 5.4.0"

  name         = local.sns.topic_name
  display_name = local.sns.display_name

  subscriptions = {
    email = {
      protocol = "email"
      endpoint = local.sns.subscription.email
    }
  }

  topic_policy_statements = {
    sub = {
      actions = [
        "sns:Publish"
      ]
      principals = [{
        type = "Service"
        identifiers = [
          "events.amazonaws.com"
        ]
      }]
    }
  }
}
