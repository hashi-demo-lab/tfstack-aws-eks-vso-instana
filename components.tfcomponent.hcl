

#AWS EKS
component "eks" {
  for_each = var.regions

  source = "./aws-eks-automode"

  inputs = {
    vpc_id                                   = var.vpc_id
    private_subnets                          = var.private_subnets
    kubernetes_version                       = var.kubernetes_version
    cluster_name                             = var.cluster_name
    tfc_hostname                             = var.tfc_hostname
    tfc_kubernetes_audience                  = var.tfc_kubernetes_audience
    enable_cluster_creator_admin_permissions = true
    eks_clusteradmin_arn                     = var.eks_clusteradmin_arn
    eks_clusteradmin_username                = var.eks_clusteradmin_username
    enable_irsa                              = var.enable_irsa
  }

  providers = {
    aws        = provider.aws.configurations[each.value]
    cloudinit  = provider.cloudinit.this
    kubernetes = provider.kubernetes.this
    time       = provider.time.this
    tls        = provider.tls.this
    null       = provider.null.this
  }
}

# # Update K8s role-binding
component "k8s-rbac" {
  for_each = var.regions

  source = "./k8s-rbac"

  inputs = {
    cluster_endpoint      = component.eks[each.value].cluster_endpoint
    tfc_organization_name = var.tfc_organization_name
    oidc_provider_status  = component.eks[each.value].oidc_provider_config_status
  }

  providers = {
    kubernetes = provider.kubernetes.configurations[each.value]
  }
}

# Vault Secrets Operator (VSO)
component "vault-secrets-operator" {
  for_each = var.regions

  source = "./hashi-vault-vso"

  inputs = {
    vso_namespace         = var.vso_namespace
    vso_chart_version     = var.vso_chart_version
    vso_replicas          = var.vso_replicas
    vault_address         = var.vault_address
    vault_connection_name = var.vault_connection_name
    vault_skip_tls_verify = var.vault_skip_tls_verify
    vault_auth_mount      = var.vault_auth_mount
    vault_kubernetes_role = var.vault_kubernetes_role
    vault_service_account = var.vault_service_account
  }

  providers = {
    kubernetes = provider.kubernetes.configurations[each.value]
    helm       = provider.helm.configurations[each.value]
  }
}

# K8s Addons - aws load balancer controller, coredns, vpc-cni, kube-proxy
component "k8s-addons" {
  for_each = var.regions

  source = "./aws-eks-addon"

  inputs = {
    cluster_name                       = component.eks[each.value].cluster_name
    vpc_id                             = var.vpc_id
    private_subnets                    = var.private_subnets
    cluster_endpoint                   = component.eks[each.value].cluster_endpoint
    cluster_version                    = component.eks[each.value].cluster_version
    oidc_provider_arn                  = component.eks[each.value].oidc_provider_arn
    cluster_certificate_authority_data = component.eks[each.value].cluster_certificate_authority_data
    oidc_binding_id                    = component.k8s-rbac[each.value].oidc_binding_id
  }

  providers = {
    kubernetes = provider.kubernetes.oidc_configurations[each.value]
    helm       = provider.helm.oidc_configurations[each.value]
    aws        = provider.aws.configurations[each.value]
    time       = provider.time.this
    random     = provider.random.this
  }
}

# #K8s addon - IBM Instana
component "k8s-addons-instana" {
  for_each = var.regions

  source = "./ibm-instana"

  inputs = {
    cluster_name                       = component.eks[each.value].cluster_name
    cluster_endpoint                   = component.eks[each.value].cluster_endpoint
    cluster_certificate_authority_data = component.eks[each.value].cluster_certificate_authority_data
    instana_agent_key                  = var.instana_agent_key
    instana_cluster_name               = var.instana_cluster_name
    instana_endpoint_host              = var.instana_endpoint_host
    instana_endpoint_port              = var.instana_endpoint_port
    # addon_version                       = var.instana_addon_version
  }

  providers = {
    kubernetes = provider.kubernetes.oidc_configurations[each.value]
    helm       = provider.helm.oidc_configurations[each.value]
  }
}

component "k8s-addons-kubecost" {
  for_each = var.regions

  source = "./ibm-kubecost"

  providers = {
    kubernetes = provider.kubernetes.oidc_configurations[each.value]
    helm       = provider.helm.oidc_configurations[each.value]
  }
}

# # Namespace
# component "k8s-namespace" {
#   for_each = var.regions

#   source = "./k8s-namespace"

#   inputs = {
#     namespace = var.namespace
#     labels = component.k8s-addons[each.value].eks_addons
#   }

#   providers = {
#     kubernetes  = provider.kubernetes.oidc_configurations[each.value]
#   }
# }

# # Deploy Hashibank
# component "deploy-hashibank" {
#   for_each = var.regions

#   source = "./hashibank-deploy"

#   inputs = {
#     hashibank_namespace = component.k8s-namespace[each.value].namespace
#   }

#   providers = {
#     kubernetes  = provider.kubernetes.oidc_configurations[each.value]
#     time = provider.time.this
#   }
# }

# removed {
#   for_each = var.regions
#   source   = "./ibm-instana"
#   from     = component.k8s-addons-instana[each.key]

#   providers = {
#     kubernetes = provider.kubernetes.configurations[each.value]
#     helm       = provider.helm.configurations[each.value]
#   }
# }