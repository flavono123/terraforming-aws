terraform {
  required_version = "~> 1.6.2"

  required_providers {
    aws = "~> 5.24"
  }
}

locals {
  iam_users = [
    "Dev-Intern"
    , "Dev-Pro"
    , "Super-Intern"
    , "Super-Pro"
  ]

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

  for_each = toset(local.iam_users)
  name     = each.key

  create_iam_access_key         = false
  create_iam_user_login_profile = true
  create_user                   = true

  force_destroy = true

  password_reset_required = false
}

module "iam_group_with_policies" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"

  for_each = local.iam_groups
  name     = each.key

  group_users = each.value.users

  custom_group_policy_arns = each.value.policy_arns
}
