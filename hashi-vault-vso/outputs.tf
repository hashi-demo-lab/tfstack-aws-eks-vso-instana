# Outputs for Vault Secrets Operator component

output "vso_release_name" {
  description = "Helm release name for VSO"
  value       = helm_release.vault_secrets_operator.name
}

output "vso_version" {
  description = "Version of VSO Helm chart deployed"
  value       = helm_release.vault_secrets_operator.version
}

# output "vault_connection_created" {
#   description = "Whether VaultConnection resource was created"
#   value       = length(kubernetes_manifest.vault_connection) > 0
# }

# output "vault_auth_created" {
#   description = "Whether VaultAuth resource was created"
#   value       = length(kubernetes_manifest.vault_auth) > 0
# }
