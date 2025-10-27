# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Terraform Stack** configuration for deploying AWS EKS (Elastic Kubernetes Service) clusters with Vault Secrets Operator (VSO) and Instana integration. It uses the Terraform Stacks feature which requires Terraform CLI 1.13.4+ and HCP Terraform.

## Key Architecture Concepts

### Terraform Stacks Structure

This repository uses Terraform Stacks with a multi-region, for_each pattern:

- **Component files** (`.tfcomponent.hcl`): Define reusable infrastructure components
- **Deployment files** (`.tfdeploy.hcl`): Define concrete deployment instances
- **Upstream Inputs**: This stack consumes outputs from an upstream landing zone stack

The stack is organized into:

1. **variables.tfcomponent.hcl**: Stack-level variable declarations including AWS and K8s identity tokens
2. **providers.tfcomponent.hcl**: Multiple provider configurations (AWS, Kubernetes, Helm, etc.)
3. **components.tfcomponent.hcl**: EKS cluster component and commented-out addons (k8s-rbac, k8s-addons, k8s-namespace, deploy-hashibank)
4. **deployments.tfdeploy.hcl**: Deployment definitions with identity tokens and upstream stack references

### Multi-Region Pattern

The stack uses `for_each = var.regions` pattern to deploy resources across multiple regions:
- AWS provider configured with `for_each` to create regional instances
- EKS component uses `for_each` to deploy clusters in each specified region
- Commented-out components also follow this pattern for future expansion

### Authentication Pattern

This stack uses **dual OIDC authentication**:
1. **AWS OIDC**: For AWS resource management
   - Identity token: `identity_token "aws"` with audience `["aws.workload.identity"]`
   - Authenticates to AWS via `assume_role_with_web_identity`
   - Variables marked as `ephemeral = true` and `sensitive = true`

2. **Kubernetes OIDC**: For K8s resource management (currently commented out in providers)
   - Identity token: `identity_token "k8s"` with audience `["k8s.workload.identity"]`
   - Used for Kubernetes and Helm provider authentication to EKS clusters
   - Enables workload identity federation between HCP Terraform and EKS

### Upstream Stack Integration

This stack consumes outputs from a landing zone stack:
```hcl
upstream_input "landingzone_stack" {
  type   = "stack"
  source = "app.terraform.io/hashicorp/hackathon/tfstack-aws-landing-zone"
}
```
This allows the EKS stack to reference VPC and networking resources created by the landing zone stack.

## Common Commands

### Lock File Management
```bash
# Update provider lock file (required after provider version changes)
terraform stacks providers-lock

# If lock file has version conflicts, remove and recreate:
rm .terraform.lock.hcl && terraform stacks providers-lock
```

### Validation
```bash
# Validate entire stack configuration
terraform stacks validate
```

### Planning and Applying
```bash
# Plan changes for a specific deployment
terraform stacks plan --deployment=development

# Apply infrastructure for a specific deployment
terraform stacks apply --deployment=development
```

### Stack Management
```bash
# Initialize stack (if needed)
terraform stacks init

# Format stack configuration files
terraform stacks fmt

# View help for any command
terraform stacks <command> -usage
```

## Component Architecture

### Active Components

1. **EKS Component** (`component "eks"`):
   - Uses `terraform-aws-modules/eks/aws` version 21.6.1
   - Deploys across regions using `for_each = var.regions`
   - Requires upstream VPC inputs: `vpc_id` and `private_subnets`
   - Configures OIDC for HCP Terraform workload identity
   - Multiple provider dependencies: aws, cloudinit, kubernetes, time, tls

### Commented-Out Components

The following components are defined but currently commented out in `components.tfcomponent.hcl`:

1. **k8s-rbac**: Kubernetes RBAC configuration for HCP Terraform
2. **k8s-addons**: AWS EKS addons (ALB controller, CoreDNS, VPC CNI, kube-proxy)
3. **k8s-namespace**: Namespace creation (default: "hashibank")
4. **deploy-hashibank**: Application deployment

These can be uncommented when needed, but require enabling the corresponding providers in `providers.tfcomponent.hcl`.

## Provider Configuration

### Active Providers

- **AWS**: Regional configurations using `for_each`, OIDC authentication
- **cloudinit**, **kubernetes**, **time**, **tls**, **local**, **random**: Single instances without configuration

### Commented-Out Providers

- **kubernetes "configurations"**: Token-based auth using EKS cluster token
- **kubernetes "oidc_configurations"**: OIDC-based auth using K8s identity token
- **helm "oidc_configurations"**: OIDC-based auth for Helm deployments

Uncomment these when enabling the k8s-addons or deploy-hashibank components.

## Configuration Patterns

### Adding New Deployments

When adding a new deployment to `deployments.tfdeploy.hcl`:

1. Define required identity tokens (aws and k8s if needed)
2. Specify the regions set (e.g., `regions = ["ap-southeast-2", "us-east-1"]`)
3. Configure EKS-specific variables:
   - `kubernetes_version`: EKS version (e.g., "1.30")
   - `cluster_name`: Unique cluster identifier
   - `eks_clusteradmin_arn`: IAM role ARN for cluster admin access
   - `eks_clusteradmin_username`: Username for cluster admin
4. Configure OIDC variables:
   - `tfc_hostname`: HCP Terraform hostname
   - `tfc_organization_name`: Your HCP Terraform organization
   - `tfc_kubernetes_audience`: Audience for K8s workload identity

### Enabling Additional Components

To enable commented-out components:

1. Uncomment the component block in `components.tfcomponent.hcl`
2. Uncomment corresponding provider configurations in `providers.tfcomponent.hcl`
3. Ensure all required variables are defined
4. Validate and test incrementally

### Multi-Region Deployment

- Current deployment uses single region: `["ap-southeast-2"]`
- To deploy to multiple regions, add to the regions set: `["ap-southeast-2", "us-east-1"]`
- All components with `for_each = var.regions` will be deployed to each region
- Ensure the upstream landing zone stack has VPCs in all target regions

## Important Constraints

- **No `terraform init`**: Stacks do not use traditional `terraform init`. Use `terraform stacks init` instead.
- **No `-upgrade` flag**: The `providers-lock` command does not support an upgrade flag. Remove the lock file to upgrade providers.
- **OIDC Required**: This stack requires OIDC trust relationships configured between HCP Terraform and both AWS IAM and EKS clusters.
- **HCP Terraform Only**: Stacks are designed for HCP Terraform and won't work with local Terraform execution.
- **Upstream Stack Dependency**: This stack depends on the landing zone stack being deployed first with appropriate VPC resources.
- **Provider Configuration**: Providers are configured using OIDC, not through environment variables or static credentials.
- **for_each Limitations**: The regional provider pattern requires all components to be compatible with for_each iteration.

## File Editing Guidelines

- When modifying regions, update the `regions` input in deployment blocks
- When enabling commented components, also enable corresponding providers
- Identity tokens should remain ephemeral and sensitive
- EKS cluster names must be unique within an AWS account/region
- IAM role ARNs must have appropriate trust relationships configured for OIDC
- Provider version constraints use `~>` for minor version flexibility
- Component dependencies must respect the for_each region pattern
- Upstream stack references should match the actual deployed stack name and organization

## Security Considerations

- Dual identity tokens (AWS and K8s) provide separate security boundaries
- All identity tokens marked as ephemeral (never persisted in state)
- Sensitive variables properly flagged to prevent exposure in logs
- OIDC eliminates need for static credentials
- EKS cluster admin access controlled via IAM role ARN
- Each deployment can use different IAM roles for least privilege access
