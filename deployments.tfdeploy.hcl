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

# upstream_input "landingzone_stack" {
#   type   = "stack"
#   source = "app.terraform.io/hashi-demos-apj/hackathon/tfstack-aws-landing-zone"
# }


# ----------------------------------------------------
# Step 3: Define Deployment Groups and Assign Rules
# ----------------------------------------------------

deployment_group "dev_group_simon" {
  # The dev group uses the auto-approval rule.
  auto_approve_checks = [
    deployment_auto_approve.safe_dev_plans
  ]
}

deployment_group "dev_group_jessica" {
  # The dev group uses the auto-approval rule.
  auto_approve_checks = [
    deployment_auto_approve.safe_dev_plans
  ]
}

deployment_group "dev_group_pranit" {
  # The dev group uses the auto-approval rule.
  auto_approve_checks = [
    deployment_auto_approve.safe_dev_plans
  ]
}

deployment_auto_approve "safe_dev_plans" {
  check {
    # This rule only passes if no resources are being deleted.
    condition = context.plan.changes.remove == 0
    reason    = "Plan has ${context.plan.changes.remove} resources to be removed. Manual approval required."
  }
}

deployment "eks-team1-simon-dev" {
  deployment_group = deployment_group.dev_group_simon
  inputs = {
    aws_identity_token = identity_token.aws.jwt
    role_arn           = "arn:aws:iam::855831148133:role/tfstacks-role"
    regions            = ["ap-southeast-2"]

    # vpc_id          = upstream_input.landingzone_stack.vpc_id_team1
    # private_subnets = upstream_input.landingzone_stack.private_subnets_team1

    vpc_id          = "vpc-078cb1d7b6ed781eb"
    private_subnets = ["subnet-04183d2a87d1d9b5a", "subnet-028b7528f2e09d2af", "subnet-0f573d24383ac66e9"]

    #EKS Cluster
    kubernetes_version = "1.34"
    cluster_name       = "eks-team1-dev1"
    enable_irsa        = true

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
  destroy = true
}

deployment "eks-team2-jessica-dev" {
  deployment_group = deployment_group.dev_group_jessica
  inputs = {
    aws_identity_token = identity_token.aws.jwt
    role_arn           = "arn:aws:iam::034362039150:role/stacks-jessicaorg-ahm-hackathon"
    regions            = ["ap-southeast-1"]

    # vpc_id          = upstream_input.landingzone_stack.vpc_id_team1
    # private_subnets = upstream_input.landingzone_stack.private_subnets_team1

    vpc_id          = "vpc-0819bfc17f32c7029"
    private_subnets = ["subnet-00a17be3b7e472148", "subnet-079327335a02c1d41", "subnet-0833c0c015c6e6e7b"]

    #EKS Cluster
    kubernetes_version = "1.34"
    cluster_name       = "eks-team2-dev1"
    enable_irsa        = true

    #EKS OIDC
    tfc_kubernetes_audience   = "k8s.workload.identity"
    tfc_hostname              = "https://app.terraform.io"
    tfc_organization_name     = "hashi-demos-apj"
    eks_clusteradmin_arn      = "arn:aws:iam::034362039150:role/aws_jessica.ang_test-developer"
    eks_clusteradmin_username = "aws_jessica.ang_test-developer"

    #K8S
    k8s_identity_token = identity_token.k8s.jwt
    namespace          = "application"

  }
  destroy = false
}

# deployment "prod" {
#deployment_group = deployment_group.dev_group
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

#Deployment for Team 3 - Pranit Raje
deployment "eks-team3-pranit-dev" {
  deployment_group = deployment_group.dev_group_pranit
  inputs = {
    aws_identity_token = identity_token.aws_team3.jwt
    role_arn           = "arn:aws:iam::124355636080:role/Terraform-service-account-role"
    regions            = ["ap-south-1"]

    # vpc_id          = upstream_input.landingzone_stack.vpc_id_team3
    # private_subnets = upstream_input.landingzone_stack.private_subnets_team3

    vpc_id          = "vpc-013867fc705b10e20"
    private_subnets = ["subnet-03bad7eca01c07ccd", "subnet-0154270c024edd15f", "subnet-05c52c563a4ca9e17"]

    #EKS Cluster
    kubernetes_version = "1.34"
    cluster_name       = "eks-team3-pranit-dev"
    enable_irsa        = true

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
  #Uncomment to destroy the deployment
  destroy = true
}