
# oidc-identity pre-requisite
# This ClusterRoleBinding grants cluster-admin permissions to the Terraform Cloud organization
# specified in tfc_organization_name, allowing OIDC-authenticated users from that organization
# to perform admin operations on the cluster
resource "kubernetes_cluster_role_binding_v1" "oidc_role" {
  metadata {
    generate_name = "oidc-identity-"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = var.tfc_organization_name
  }

  # Ensure OIDC provider is configured before creating the role binding
  depends_on = [var.oidc_provider_status]
}
