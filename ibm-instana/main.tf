# #Install IBM Instana Agent via Helm

# resource "aws_eks_addon" "instana" {
#   cluster_name = var.cluster_name
#   addon_name   = "ibm-software_ibm-instana-observability"
#   addon_version = var.instana_addon_version
# }


resource "helm_release" "ibm_instana_agent" {
  name       = "instana-agent"
  repository = "https://agents.instana.io/helm"
  chart      = "instana-agent"
  namespace  = "instana-agent"
  create_namespace = true

  values = [
    yamlencode({
      agent = {
        key         = var.instana_agent_key
        downloadKey = var.instana_agent_key
        endpointHost = var.instana_endpoint_host
        endpointPort = var.instana_endpoint_port
      }
      cluster = {
        name = var.instana_cluster_name
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