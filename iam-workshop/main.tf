terraform {
  required_version = "~> 1.6.2"

  required_providers {
    aws = "~> 5.24"
  }
}

locals {
  iam_users = {
    Dev-Intern = {
      policy_arns = []
    },
    Dev-Pro = {
      policy_arns = []
    },
    Super-Intern = {
      policy_arns = []
    },
    Super-Pro = {
      policy_arns = [
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
      ]
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
}

module "iam_group_with_policies" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"

  for_each = local.iam_groups
  name     = each.key

  group_users = each.value.users

  custom_group_policy_arns = each.value.policy_arns
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
