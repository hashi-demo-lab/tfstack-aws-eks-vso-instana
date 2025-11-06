resource "helm_release" "ibm_kubecost" {
  name       = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  namespace  = "kubecost"
  create_namespace = true

  values = [
    yamlencode({
      # kubecostProductConfigs = {
      #   global = {
      #     kubecostToken = var.kubecost_token
      #   }
      # }
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