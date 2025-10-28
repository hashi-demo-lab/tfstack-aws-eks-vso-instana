variable "regions" {
  type = set(string)
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = set(string)
}

variable "aws_identity_token" {
  type = string
  ephemeral = true
  sensitive = true
}

variable "k8s_identity_token" {
  type = string
  ephemeral = true
  sensitive = true
}

variable "workload_idp_name" {
  type = string
  default = "tfstacks-workload-identity-provider"
}

variable "aws_auth_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "role_arn" {
  type = string
}

variable "kubernetes_version" {
  type = string
  default = "1.29"
}

variable "cluster_name" {
  type = string
  default = "eks-cluster"
}

variable "namespace" {
  type = string
  default = "hashibank"
}

variable "tfc_hostname" {
  type = string
}

variable "tfc_organization_name" {
  type = string
}

variable "tfc_kubernetes_audience" {
  type = string
}
variable "eks_clusteradmin_arn" {
  type = string
}

variable "eks_clusteradmin_username" {
  type = string
}

# Vault Secrets Operator (VSO) variables
variable "vso_namespace" {
  description = "Namespace for Vault Secrets Operator"
  type        = string
  default     = "vault-secrets-operator-system"
}

variable "vso_chart_version" {
  description = "Helm chart version for Vault Secrets Operator"
  type        = string
  default     = "0.10.0"
}

variable "vso_replicas" {
  description = "Number of VSO controller replicas"
  type        = number
  default     = 1
}

variable "vault_address" {
  description = "Address of the Vault server"
  type        = string
  default     = ""
}

variable "vault_connection_name" {
  description = "Name of the VaultConnection resource"
  type        = string
  default     = "default"
}

variable "vault_skip_tls_verify" {
  description = "Skip TLS verification for Vault connection"
  type        = bool
  default     = false
}

variable "vault_auth_mount" {
  description = "Vault auth mount path for Kubernetes authentication"
  type        = string
  default     = ""
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

