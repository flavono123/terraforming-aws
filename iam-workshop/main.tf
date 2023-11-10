terraform {
  required_version = "~> 1.6.2"

  required_providers {
    aws = "~> 5.24"
  }
}

data "aws_caller_identity" "current" {}

locals {
  iam_users = {
    Dev-Intern = {
      policy_arns          = []
      permissions_boundary = ""
    },
    Dev-Pro = {
      policy_arns          = []
      permissions_boundary = ""
    },
    Super-Intern = {
      policy_arns          = []
      permissions_boundary = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    },
    Super-Pro = {
      policy_arns = [
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
      ]
      permissions_boundary = ""
    }
  }

  # Group
  iam_groups = {
    Dev = {
      users       = ["Dev-Intern", "Dev-Pro"]
      policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
    },
    Super = {
      users       = ["Super-Intern", "Super-Pro"]
      policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
  }

  s3_bucket_name_prefix = "builders-s3-"
  s3_bucket_name        = "${local.s3_bucket_name_prefix}${var.s3_bucket_name_suffix}"

  inline_policy_name = "builders-inline"
}

module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 5.30"

  for_each = local.iam_users
  name     = each.key

  create_iam_access_key         = false
  create_iam_user_login_profile = true
  create_user                   = true

  force_destroy = true

  password_reset_required = false

  policy_arns = each.value.policy_arns

  permissions_boundary = each.value.permissions_boundary
}

module "iam_group_with_policies" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"

  for_each = local.iam_groups
  name     = each.key

  group_users = each.value.users

  custom_group_policy_arns = each.value.policy_arns

  # IAM 사용자 자신과 그룹에 대한 권한을 제외한 대부분 서비스 권한을 제한
  # https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-group-with-policies#input_attach_iam_self_management_policy
  attach_iam_self_management_policy = false
}

# Caveat: 워크샵처럼 Super-Pro IAM 사용자로서 만들지 않음
# 워크샵에선 Super-Pro 는 AWS Management Console에서 직접 생성
# Super-Pro 권한으로 만들려면 Acces key 생성을 활성화하고 alias provider로 생성할 수도 있을 것
# (하지만 그렇게하면 access key를 만들지 않는 워크샵 내용과 달라짐)
module "super_pro_ec2_create" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.5"

  name = "Super-Pro-EC2-Create"

  instance_type = "t2.micro"
}

module "builders_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.15"

  bucket = local.s3_bucket_name

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "Statement1"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Dev-Intern"
        }
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "${module.builders_s3_bucket.s3_bucket_arn}/*"
      }
    ]
  })
}

# aws_iam_user_policy 리소스를 사용; 인라인 정책은 모듈이 없다
resource "aws_iam_user_policy" "builders_inline" {
  name = local.inline_policy_name
  user = module.iam_user["Dev-Intern"].iam_user_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:ListBucket"
        ]
        Resource = "*"
      },
    ]
  })
}
