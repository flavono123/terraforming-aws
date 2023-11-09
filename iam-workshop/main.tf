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
