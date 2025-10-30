# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cluster_endpoint" {
  type        = map(string)
  description = "VPC IDs by region"
  value       = { for k, v in component.eks : k => v.cluster_endpoint }
}

output "cluster_certificate_authority_data" {
  type        = map(string)
  description = "VPC IDs by region"
  value       = { for k, v in component.eks : k => v.cluster_certificate_authority_data }
}
