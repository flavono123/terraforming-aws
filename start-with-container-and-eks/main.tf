terraform {
  required_version = "~> 1.6.3"

  required_providers {
    aws        = "~> 5.25"
    kubernetes = "~> 2.23.0"
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

data "aws_availability_zones" "available" {}

locals {
  # VPC
  vpc_name        = "terraforming-aws-vpc"
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  vpc_cidr        = "10.0.0.0/16"
  partition       = cidrsubnets(local.vpc_cidr, 1, 1)
  private_subnets = cidrsubnets(local.partition[0], 2, 2)
  public_subnets  = cidrsubnets(local.partition[1], 2, 2)

  # EKS
  cluster_name    = "terraforming-aws-eks"
  cluster_version = "1.28" # current latest
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  # Single NAT Gateway; minimize the costs
  # ref. https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest#single-nat-gateway
  enable_nat_gateway = true
  single_nat_gateway = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default_ng = {
      min_size     = 1
      max_size     = 2
      desired_size = 2

      instance_types = ["t2.small"]
      capacity_type  = "SPOT"
    }
  }
}

resource "terraform_data" "eks_kubeconfig" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig \
        --name ${module.eks.cluster_name} \
        --alias ${module.eks.cluster_name} \
        --user-alias ${module.eks.cluster_name}

      sed -i s%${trimsuffix(module.eks.cluster_arn, module.eks.cluster_name)}%% -- $HOME/.kube/config

      echo <<EOF
      Caveats:
        Your current kubeconfig is updated, the context, cluster and user are with same name ${module.eks.cluster_name}.
        Remove when destorying this resources:
        kubectl ctx -d ${module.eks.cluster_name} # or "kubectl config delete-context ${module.eks.cluster_name}"
        kubectl config delete-cluster ${module.eks.cluster_name}
        kubectl config delete-user ${module.eks.cluster_name}
    EOT
  }
}

check "eks_status" {
  assert {
    condition     = module.eks.cluster_status == "ACTIVE"
    error_message = "EKS cluster is ${module.eks.cluster_status}"
  }
}


# k2tf -f manifests/nginx-orange.yaml
resource "kubernetes_pod" "nginx_orange" {
  metadata {
    name = "nginx-orange"

    labels = {
      run = "nginx-orange"
    }
  }

  spec {
    container {
      name  = "orange"
      image = "nginx"
    }
  }
}

