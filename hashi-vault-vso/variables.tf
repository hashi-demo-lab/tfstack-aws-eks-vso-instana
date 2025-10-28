# Variables for Vault Secrets Operator (VSO) installation

variable "vso_namespace" {
  description = "Namespace for Vault Secrets Operator"
  type        = string
  default     = "vault-secrets-operator-system"
}

variable "vso_chart_version" {
  description = "Helm chart version for Vault Secrets Operator"
  type        = string
  default     = "0.10.0" # Update to latest version as needed
}

variable "vso_image_tag" {
  description = "Docker image tag for Vault Secrets Operator"
  type        = string
  default     = "0.10.0" # Should match chart version
}

variable "vso_replicas" {
  description = "Number of VSO controller replicas"
  type        = number
  default     = 1
}

variable "create_default_vault_connection" {
  description = "Whether to create a default VaultConnection in the Helm chart"
  type        = bool
  default     = false
}

# Vault connection settings
variable "vault_address" {
  description = "Address of the Vault server (e.g., http://vault.vault.svc.cluster.local:8200)"
  type        = string
  default     = ""
}

variable "vault_connection_name" {
  description = "Name of the VaultConnection resource"
  type        = string
  default     = "default"
}

variable "vault_skip_tls_verify" {
  description = "Skip TLS verification for Vault connection (use only for dev/test)"
  type        = bool
  default     = false
}

# Vault authentication settings
variable "vault_auth_mount" {
  description = "Vault auth mount path for Kubernetes authentication"
  type        = string
  default     = ""
}

variable "vault_auth_name" {
  description = "Name of the VaultAuth resource"
  type        = string
  default     = "default"
}

variable "vault_kubernetes_role" {
  description = "Vault Kubernetes auth role name"
  type        = string
  default     = "vso"
}

variable "vault_service_account" {
  description = "Kubernetes service account for Vault authentication"
  type        = string
  default     = "default"
}
