# Vault Secrets Operator (VSO) Installation
# Based on: https://developer.hashicorp.com/vault/tutorials/kubernetes/vault-secrets-operator


# Install Vault Secrets Operator using Helm
resource "helm_release" "vault_secrets_operator" {
  name       = "vault-secrets-operator"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  version    = var.vso_chart_version
  create_namespace = true
  namespace  = var.vso_namespace

  # Values from the HashiCorp tutorial
  values = [
    yamlencode({
      defaultVaultConnection = {
        enabled = var.create_default_vault_connection
      }

      controller = {
        manager = {
          image = {
            repository = "hashicorp/vault-secrets-operator"
            tag        = var.vso_image_tag
          }
          resources = {
            limits = {
              cpu    = "500m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "64Mi"
            }
          }
        }
      }
    })
  ]

  # Additional configuration via set_list for nested values
  set {
    name  = "controller.replicas"
    value = tostring(var.vso_replicas)
  }
}

# Optional: Create VaultConnection resource if Vault address is provided
# resource "kubernetes_manifest" "vault_connection" {
#   count = var.vault_address != "" ? 1 : 0

#   manifest = {
#     apiVersion = "secrets.hashicorp.com/v1beta1"
#     kind       = "VaultConnection"
#     metadata = {
#       name      = var.vault_connection_name
#       namespace = kubernetes_namespace.vault_secrets_operator.metadata[0].name
#     }
#     spec = {
#       address = var.vault_address
#       # Add skipTLSVerify only for development/testing
#       skipTLSVerify = var.vault_skip_tls_verify
#     }
#   }

#   depends_on = [helm_release.vault_secrets_operator]
# }

# # Optional: Create VaultAuth resource for Kubernetes authentication
# resource "kubernetes_manifest" "vault_auth" {
#   count = var.vault_address != "" && var.vault_auth_mount != "" ? 1 : 0

#   manifest = {
#     apiVersion = "secrets.hashicorp.com/v1beta1"
#     kind       = "VaultAuth"
#     metadata = {
#       name      = var.vault_auth_name
#       namespace = kubernetes_namespace.vault_secrets_operator.metadata[0].name
#     }
#     spec = {
#       vaultConnectionRef = kubernetes_manifest.vault_connection[0].manifest.metadata.name
#       method             = "kubernetes"
#       mount              = var.vault_auth_mount
#       kubernetes = {
#         role           = var.vault_kubernetes_role
#         serviceAccount = var.vault_service_account
#       }
#     }
#   }

#   depends_on = [
#     helm_release.vault_secrets_operator,
#     kubernetes_manifest.vault_connection
#   ]
# }
