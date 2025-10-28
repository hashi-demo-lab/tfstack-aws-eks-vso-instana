identity_token "aws" {
  audience = ["aws.workload.identity"]
}

identity_token "k8s" {
  audience = ["k8s.workload.identity"]
}

## Identity Token for Pranit's AWS Account
identity_token "aws_team3" {
  audience = ["aws.workload.identity"]
}

identity_token "k8s_team3" {
  audience = ["k8s.workload.identity"]
}
###

upstream_input "landingzone_stack" {
  type   = "stack"
  source = "app.terraform.io/hashi-demos-apj/hackathon/tfstack-aws-landing-zone"
}

deployment "eks-team1-simon-dev" {
  inputs = {
    aws_identity_token = identity_token.aws.jwt
    role_arn           = "arn:aws:iam::855831148133:role/tfstacks-role"
    regions            = ["ap-southeast-2"]

    vpc_id          = upstream_input.landingzone_stack.vpc_id_team1
    private_subnets = upstream_input.landingzone_stack.private_subnets_team1

    #EKS Cluster
    kubernetes_version = "1.34"
    cluster_name       = "eks-team1-dev1"

    #EKS OIDC
    tfc_kubernetes_audience   = "k8s.workload.identity"
    tfc_hostname              = "https://app.terraform.io"
    tfc_organization_name     = "hashi-demos-apj"
    eks_clusteradmin_arn      = "arn:aws:iam::855831148133:role/aws_simon.lynch_test-developer"
    eks_clusteradmin_username = "aws_simon.lynch_test-developer"

    #K8S
    k8s_identity_token = identity_token.k8s.jwt
    namespace          = "application"

  }
  destroy = false
}

# deployment "prod" {
#   inputs = {
#     aws_identity_token = identity_token.aws.jwt
#     role_arn            = "arn:aws:iam::855831148133:role/tfstacks-role"
#     regions             = ["ap-southeast-2"]
#     vpc_name = "vpc-prod2"
#     vpc_cidr = "10.20.0.0/16"

#     #EKS Cluster
#     kubernetes_version = "1.30"
#     cluster_name = "eksprod02"

#     #EKS OIDC
#     tfc_kubernetes_audience = "k8s.workload.identity"
#     tfc_hostname = "https://app.terraform.io"
#     tfc_organization_name = "hashi-demos-apj"
#     eks_clusteradmin_arn = "arn:aws:iam::855831148133:role/aws_simon.lynch_test-developer"
#     eks_clusteradmin_username = "aws_simon.lynch_test-developer"

#     #K8S
#     k8s_identity_token = identity_token.k8s.jwt
#     namespace = "hashibank"

#   }
# }

# orchestrate "auto_approve" "safe_plans_dev" {
#   check {
#       # Only auto-approve in the development environment if no resources are being removed
#       condition = context.plan.changes.remove == 0 && context.plan.deployment == deployment.development
#       reason = "Plan has ${context.plan.changes.remove} resources to be removed."
#   }
# }

# Deployment for Team 3 - Pranit Raje
deployment "eks-team3-pranit-dev" {
  inputs = {
    aws_identity_token = identity_token.aws_team3.jwt
    role_arn           = "arn:aws:iam::124355636080:role/Terraform-service-account-role"
    regions            = ["ap-south-1"]

    vpc_id          = upstream_input.landingzone_stack.vpc_id_team3
    private_subnets = upstream_input.landingzone_stack.private_subnets_team3

    #EKS Cluster
    kubernetes_version = "1.34"
    cluster_name       = "eks-team3-pranit-dev"

    #EKS OIDC
    tfc_kubernetes_audience   = "k8s.workload.identity"
    tfc_hostname              = "https://app.terraform.io"
    tfc_organization_name     = "hashi-demos-apj"
    eks_clusteradmin_arn      = "arn:aws:iam::124355636080:role/aws_pranit.raje_test-developer"
    eks_clusteradmin_username = "aws_pranit.raje_test-developer"

    #K8S
    k8s_identity_token = identity_token.k8s_team3.jwt
    namespace          = "application"

  }
  destroy = false
}