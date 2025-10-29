locals {
  tags = {
    Blueprint  = var.cluster_name
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.6.1"

  name                   = var.cluster_name
  kubernetes_version     = var.kubernetes_version 
  endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_irsa = var.enable_irsa

  create_cloudwatch_log_group = false #disabling logs for cost - lab only
  kms_key_deletion_window_in_days = 7

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }
  
  timeouts = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
  
  access_entries = {
      # One access entry with a policy associated
      single = {
        kubernetes_groups = []
        principal_arn     = var.eks_clusteradmin_arn
        username          = var.eks_clusteradmin_username

        policy_associations = {
          single = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type       = "cluster"
            }
          }
        }
      }
    }


  tags = local.tags


}

data "aws_eks_cluster" "upstream" {
  depends_on = [module.eks]
  name = var.cluster_name

}

data "aws_eks_cluster_auth" "upstream_auth" {
  depends_on = [module.eks]
  name = var.cluster_name
}


resource "aws_eks_identity_provider_config" "oidc_config" {
  depends_on = [module.eks]
  cluster_name = var.cluster_name

  oidc {
    identity_provider_config_name = "tfstack-terraform-cloud"
    client_id                     = var.tfc_kubernetes_audience
    issuer_url                    = var.tfc_hostname
    username_claim                = "sub"
    groups_claim                  = "terraform_organization_name"
  }
}

