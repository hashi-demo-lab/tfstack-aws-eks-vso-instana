# Terraform Stacks - AWS EKS with VSO and Instana

A comprehensive Terraform Stacks configuration for deploying and managing Amazon EKS clusters at scale across multiple AWS accounts with integrated observability and secrets management.

## 🎯 Overview

This Terraform Stack orchestrates the deployment of production-ready Amazon EKS clusters with:

- **AWS EKS Auto Mode** - Simplified cluster management with auto-scaling node groups
- **HashiCorp Vault Secrets Operator (VSO)** - Kubernetes-native secrets synchronization from Vault
- **IBM Instana** - Application Performance Monitoring (APM) and observability
- **IBM Kubecost** - Kubernetes cost monitoring and optimization
- **Essential EKS Add-ons** - CoreDNS, VPC-CNI, Kube-proxy, AWS Load Balancer Controller
- **Multi-Account/Multi-Region Support** - Deploy across different teams and AWS accounts
- **RBAC Configuration** - Secure Kubernetes access management with OIDC integration

## 🏗️ Architecture

This stack is designed for multi-team deployments with isolated AWS accounts:

```
┌─────────────────────────────────────────────────────────┐
│  HCP Terraform (Terraform Cloud)                        │
│  - Workload Identity Provider                           │
│  - Variable Sets (IAM Roles, Instana Keys)             │
└─────────────────────────┬───────────────────────────────┘
                          │
           ┌──────────────┴──────────────┐
           │                             │
┌──────────▼──────────┐       ┌──────────▼──────────┐
│  Upstream Stack     │       │  This Stack (EKS)   │
│  Landing Zone       │       │  - Components        │
│  - VPC              │◄──────┤  - Deployments       │
│  - Subnets          │       │  - Providers         │
│  - Networking       │       └──────────┬───────────┘
└─────────────────────┘                  │
                                         │
        ┌────────────────────────────────┼────────────────────────────┐
        │                                │                            │
┌───────▼────────┐           ┌──────────▼────────┐       ┌──────────▼────────┐
│  Team 1        │           │  Team 2           │       │  Team 3           │
│  (Simon)       │           │  (Jessica)        │       │  (Pranit)         │
│  AWS Account   │           │  AWS Account      │       │  AWS Account      │
│  Region: ap-   │           │  Region: ap-      │       │  Region: ap-      │
│  southeast-2   │           │  southeast-1      │       │  south-1          │
│                │           │                   │       │                   │
│  ┌──────────┐  │           │  ┌──────────┐     │       │  ┌──────────┐     │
│  │EKS Auto  │  │           │  │EKS Auto  │     │       │  │EKS Auto  │     │
│  │Mode      │  │           │  │Mode      │     │       │  │Mode      │     │
│  │          │  │           │  │          │     │       │  │          │     │
│  │ ├─RBAC   │  │           │  │ ├─RBAC   │     │       │  │ ├─RBAC   │     │
│  │ ├─VSO    │  │           │  │ ├─VSO    │     │       │  │ ├─VSO    │     │
│  │ ├─Addons │  │           │  │ ├─Addons │     │       │  │ ├─Addons │     │
│  │ ├─Instana│  │           │  │ ├─Instana│     │       │  │ ├─Instana│     │
│  │ └─Kubecost│ │           │  │ └─Kubecost│    │       │  │ └─Kubecost│    │
│  └──────────┘  │           │  └──────────┘     │       │  └──────────┘     │
└────────────────┘           └───────────────────┘       └───────────────────┘
```

## 📋 Prerequisites

### 1. HCP Terraform (Terraform Cloud) Setup

- **Organization**: Must be part of HCP Terraform organization (e.g., `hashi-demos-apj`)
- **Project**: Create or use existing project (e.g., `hackathon`)
- **Stack Configuration**: This stack should be configured as a Terraform Stack deployment

### 2. Upstream Dependencies

This stack depends on a **Landing Zone Stack** that provides:
- VPC and networking resources
- Private subnets for EKS cluster
- Required networking infrastructure

**Upstream Stack Reference**:
```hcl
upstream_input "landingzone_stack" {
  type   = "stack"
  source = "app.terraform.io/hashi-demos-apj/hackathon/tfstack-aws-landing-zone"
}
```

### 3. AWS Account Requirements

For each team/deployment:
- **AWS Account** with appropriate permissions
- **IAM Role** for HCP Terraform with trust relationship configured for workload identity
- **VPC and Subnets** created (can be from upstream stack or hardcoded)
- **EKS Service Role** permissions
- **EC2 permissions** for node groups

### 4. Required HCP Terraform Variable Sets

#### Variable Set: `tfstacks_vars_role_arn`

This variable set stores IAM role ARNs for each deployment:

```hcl
# Category: terraform
vpc-team1-simon-dev_role_arn     = "arn:aws:iam::855831148133:role/tfstacks-role"
vpc-team2-jessica-dev_role_arn   = "arn:aws:iam::034362039150:role/stacks-jessicaorg-ahm-hackathon"
vpc-team3-pranit-dev_role_arn    = "arn:aws:iam::124355636080:role/Terraform-service-account-role"
```

**Steps to create**:
1. Navigate to your HCP Terraform organization settings
2. Go to **Variable Sets** → **Create Variable Set**
3. Name: `tfstacks_vars_role_arn`
4. Add variables for each team's IAM role ARN
5. Apply to your project/workspace

#### Variable Set: `tfstacks_vars_instana`

This variable set stores IBM Instana configuration:

```hcl
# Category: terraform (mark as sensitive)
instana_key = "your-instana-agent-key-here"
```

**Steps to create**:
1. Navigate to your HCP Terraform organization settings
2. Go to **Variable Sets** → **Create Variable Set**
3. Name: `tfstacks_vars_instana`
4. Add variable: `instana_key` (mark as **Sensitive**)
5. Get your Instana agent key from IBM Instana dashboard:
   - Login to [IBM Instana](https://www.ibm.com/products/instana)
   - Navigate to **Settings** → **Agent** → **Installing Instana Agents**
   - Copy the **Agent Key**
6. Apply to your project/workspace

### 5. Workload Identity Configuration

Configure AWS workload identity for HCP Terraform:

**IAM Trust Policy Example**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/app.terraform.io"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "app.terraform.io:aud": "aws.workload.identity"
        },
        "StringLike": {
          "app.terraform.io:sub": "organization:<ORG_NAME>:project:<PROJECT_NAME>:workspace:<WORKSPACE_NAME>:run_phase:*"
        }
      }
    }
  ]
}
```

## 📦 Components

### 1. AWS EKS Auto Mode (`aws-eks-automode/`)

Deploys Amazon EKS cluster with auto-scaling capabilities:
- **Kubernetes Version**: Configurable (1.29-1.34)
- **Compute Config**: General-purpose node pools
- **IRSA**: IAM Roles for Service Accounts enabled
- **Access Management**: Cluster admin permissions via IAM roles
- **Public Endpoint**: Enabled for management

**Key Features**:
- Simplified node management with Auto Mode
- Automatic scaling based on workload
- Cost-efficient with compute optimization

### 2. Kubernetes RBAC (`k8s-rbac/`)

Manages Kubernetes role-based access control:
- OIDC integration with HCP Terraform
- ClusterRoleBindings for service accounts
- Secure access management for CI/CD pipelines

### 3. HashiCorp Vault Secrets Operator (`hashi-vault-vso/`)

Deploys Vault Secrets Operator for Kubernetes:
- **Helm Chart Version**: 0.10.0 (configurable)
- **Namespace**: `vault-secrets-operator-system`
- **Features**:
  - Automatic secret synchronization from Vault to Kubernetes
  - Native Kubernetes authentication
  - Dynamic secret rotation
  - VaultConnection and VaultAuth resources

**Configuration**:
```hcl
vso_namespace         = "vault-secrets-operator-system"
vso_chart_version     = "0.10.0"
vault_address         = "https://vault.example.com"
vault_auth_mount      = "kubernetes"
vault_kubernetes_role = "vso"
```

### 4. EKS Add-ons (`aws-eks-addon/`)

Essential Kubernetes add-ons using EKS Blueprints:
- **CoreDNS**: DNS service discovery
- **VPC-CNI**: AWS VPC networking for pods
- **Kube-proxy**: Network proxy for services
- **AWS Load Balancer Controller**: Ingress and LoadBalancer management

### 5. IBM Instana Agent (`ibm-instana/`)

Application Performance Monitoring:
- **Helm Chart**: Official Instana agent
- **Namespace**: `instana-agent`
- **Features**:
  - Full-stack observability
  - Automatic service discovery
  - Real-time metrics and traces
  - Kubernetes cluster monitoring

**Configuration**:
```hcl
instana_agent_key     = "<from variable set>"
instana_cluster_name  = "eks-team1-dev1"
instana_endpoint_host = "ingress-blue-saas.instana.io"
instana_endpoint_port = 443
```

### 6. IBM Kubecost (`ibm-kubecost/`)

Kubernetes cost monitoring and optimization:
- Real-time cost allocation
- Resource efficiency insights
- Budget alerts and recommendations

## 🚀 Deployment

### Step 1: Clone and Configure

```bash
git clone <repository-url>
cd tfstack-aws-eks-vso-instana
```

### Step 2: Review Deployment Configuration

Edit [deployments.tfdeploy.hcl](deployments.tfdeploy.hcl) to configure your deployments:

```hcl
deployment "eks-team1-simon-dev" {
  deployment_group = deployment_group.dev_group_simon
  inputs = {
    # Identity tokens
    aws_identity_token = identity_token.aws.jwt
    k8s_identity_token = identity_token.k8s.jwt
    
    # AWS Configuration
    role_arn = store.varset.stacks_role_config.stable.vpc-team1-simon-dev_role_arn
    regions  = ["ap-southeast-2"]
    
    # VPC Configuration
    vpc_id          = "vpc-078cb1d7b6ed781eb"
    private_subnets = ["subnet-xxx", "subnet-yyy", "subnet-zzz"]
    
    # EKS Configuration
    kubernetes_version = "1.34"
    cluster_name       = "eks-team1-dev1"
    enable_irsa        = true
    
    # OIDC Configuration
    tfc_kubernetes_audience   = "k8s.workload.identity"
    tfc_hostname              = "https://app.terraform.io"
    tfc_organization_name     = "hashi-demos-apj"
    eks_clusteradmin_arn      = "arn:aws:iam::xxxxx:role/admin-role"
    eks_clusteradmin_username = "admin-user"
    
    # Application Configuration
    namespace = "application"
  }
  
  # Set to false to deploy, true to destroy
  destroy = false
}
```

### Step 3: Initialize and Deploy

Using HCP Terraform UI:
1. Navigate to your Stack in HCP Terraform
2. Click **Start new run**
3. Review the plan
4. Approve and apply

Using Terraform CLI (if configured):
```bash
terraform init
terraform plan
terraform apply
```

### Step 4: Verify Deployment

```bash
# Configure kubectl
aws eks update-kubeconfig --name eks-team1-dev1 --region ap-southeast-2

# Check cluster status
kubectl cluster-info
kubectl get nodes

# Verify VSO installation
kubectl get pods -n vault-secrets-operator-system

# Verify Instana agent
kubectl get pods -n instana-agent

# Check EKS add-ons
kubectl get pods -n kube-system
```

## ⚙️ Configuration Variables

### Core Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `regions` | `set(string)` | AWS regions for deployment | - |
| `vpc_id` | `string` | VPC ID for EKS cluster | - |
| `private_subnets` | `set(string)` | Private subnet IDs | - |
| `kubernetes_version` | `string` | EKS Kubernetes version | `1.29` |
| `cluster_name` | `string` | EKS cluster name | `eks-cluster` |
| `enable_irsa` | `bool` | Enable IRSA | `false` |

### Vault Secrets Operator Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `vso_namespace` | `string` | VSO namespace | `vault-secrets-operator-system` |
| `vso_chart_version` | `string` | Helm chart version | `0.10.0` |
| `vault_address` | `string` | Vault server address | `""` |
| `vault_auth_mount` | `string` | Vault auth mount path | `""` |
| `vault_kubernetes_role` | `string` | Vault K8s auth role | `vso` |

### Instana Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `instana_agent_key` | `string` | Instana agent key (sensitive) | `""` |
| `instana_cluster_name` | `string` | Cluster name in Instana | `""` |
| `instana_endpoint_host` | `string` | Instana endpoint | `ingress-blue-saas.instana.io` |
| `instana_endpoint_port` | `number` | Instana endpoint port | `443` |

## 🔐 Security Considerations

1. **Workload Identity**: Use workload identity instead of long-lived credentials
2. **Sensitive Variables**: Store sensitive data in HCP Terraform variable sets (marked as sensitive)
3. **RBAC**: Implement least-privilege access for cluster administrators
4. **Network Security**: Deploy EKS in private subnets with restricted security groups
5. **Secrets Management**: Use Vault Secrets Operator for application secrets

## 📊 Deployment Groups and Auto-Approval

This stack includes deployment groups with auto-approval rules:

```hcl
deployment_auto_approve "safe_dev_plans" {
  check {
    # Only auto-approve if no resources are being deleted
    condition = context.plan.changes.remove == 0
    reason    = "Plan has ${context.plan.changes.remove} resources to be removed. Manual approval required."
  }
}
```

**Development Deployments**: Auto-approve when no resources are being removed
**Production Deployments**: Always require manual approval (configure separately)

## 🔧 Troubleshooting

### Issue: EKS Cluster Creation Fails

**Solution**: Verify IAM role permissions and trust relationships

```bash
aws sts get-caller-identity
aws eks describe-cluster --name <cluster-name> --region <region>
```

### Issue: Instana Agent Not Connecting

**Solutions**:
1. Verify agent key in variable set
2. Check Instana endpoint accessibility
3. Review agent logs:
```bash
kubectl logs -n instana-agent -l app.kubernetes.io/name=instana-agent
```

### Issue: VSO Not Syncing Secrets

**Solutions**:
1. Verify Vault connection and authentication
2. Check VaultConnection resource:
```bash
kubectl get vaultconnection -n vault-secrets-operator-system
kubectl describe vaultauth -n vault-secrets-operator-system
```

### Issue: AWS Load Balancer Controller Not Working

**Solution**: Verify IRSA and IAM permissions:
```bash
kubectl get sa -n kube-system aws-load-balancer-controller -o yaml
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

## 🧪 Testing

### Verify EKS Cluster

```bash
# Get cluster info
aws eks describe-cluster --name <cluster-name> --region <region>

# Update kubeconfig
aws eks update-kubeconfig --name <cluster-name> --region <region>

# Test cluster access
kubectl get nodes
kubectl get pods --all-namespaces
```

### Test VSO Integration

```bash
# Create a test VaultStaticSecret
cat <<EOF | kubectl apply -f -
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: test-secret
  namespace: default
spec:
  vaultAuthRef: default
  mount: secret
  path: myapp/config
  destination:
    name: test-secret
    create: true
  refreshAfter: 30s
EOF

# Verify secret creation
kubectl get secret test-secret -o yaml
```

### Monitor Instana Dashboard

1. Login to IBM Instana: https://ingress-blue-saas.instana.io
2. Navigate to **Infrastructure** → **Kubernetes**
3. Find your cluster by name
4. Verify metrics and traces

## 📚 Additional Resources

- [Terraform Stacks Documentation](https://developer.hashicorp.com/terraform/cloud-docs/stacks)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [EKS Blueprints](https://aws-ia.github.io/terraform-aws-eks-blueprints/)
- [Vault Secrets Operator](https://developer.hashicorp.com/vault/docs/platform/k8s/vso)
- [IBM Instana Documentation](https://www.ibm.com/docs/en/instana-observability)
- [HCP Terraform Workload Identity](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials)

## 🤝 Contributing

For hackathon teams:
1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## 📝 License

See [LICENSE](LICENSE) file for details.

## 👥 Team

- **Team 1 (Simon)**: AWS Account 855831148133, Region: ap-southeast-2
- **Team 2 (Jessica)**: AWS Account 034362039150, Region: ap-southeast-1
- **Team 3 (Pranit)**: AWS Account 124355636080, Region: ap-south-1

## 🎉 Acknowledgments

This stack demonstrates HashiCorp Terraform Stacks capabilities for managing Kubernetes infrastructure at scale with integrated observability and security best practices.
