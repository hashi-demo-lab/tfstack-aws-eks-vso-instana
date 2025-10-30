# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


output "eks_cluster_endpoint" {
  description = "string"
  type        = string
  value       = { for k, v in component.eks : k => v.cluster_endpoint }
  sensitive   = false
  ephemeral   = false
}

output "eks_cluster_certificate_authority_data" {
  description = "string"
  type        = string
  value       = { for k, v in component.eks : k => v.cluster_certificate_authority_data }
  sensitive   = false
  ephemeral   = false
}
