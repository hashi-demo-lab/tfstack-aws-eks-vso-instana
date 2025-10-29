variable "tfc_organization_name" {
  type    = string
}

variable "cluster_endpoint" {
  type    = string
}

variable "oidc_provider_status" {
  type        = string
  description = "OIDC provider configuration status to ensure dependency"
}