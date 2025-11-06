resource "helm_release" "ibm_kubecost" {
  name       = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  version    = "2.4.3"  # Use a stable version before 2.9.x
  namespace  = "kubecost"
  create_namespace = true

  values = [
    yamlencode({
      global = {
        clusterId = var.cluster_name
      }
      # For Kubecost 2.9.x, cluster_id must be set in both global and kubecostProductConfigs
      kubecostProductConfigs = {
        clusterName = var.cluster_name
      }
      prometheus = {
        enabled = false
      }
      grafana = {
        enabled = false
      }
      resources = {
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
      }
    })
  ]
  
}