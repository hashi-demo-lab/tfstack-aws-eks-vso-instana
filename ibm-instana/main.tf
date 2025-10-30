# #Install IBM Instana Agent via Helm

resource "aws_eks_addon" "instana" {
  cluster_name = var.cluster_name
  addon_name   = "ibm-software_ibm-instana-observability"
}


# resource "helm_release" "ibm_instana_agent" {
#   name       = "instana-agent"
#   repository = "https://agents.instana.io/helm"
#   chart     = "instana-agent"
#   namespace = "instana-agent"
#   create_namespace = true

#   values = [
#     yamlencode({
#       agentKey = var.instana_agent_key
#       clusterName = var.instana_cluster_name
#       endpointHost = var.instana_endpoint_host
#       endpointPort = var.instana_endpoint_port
#       resources = {
#         limits = {
#           cpu    = "500m"
#           memory = "512Mi"
#         }
#         requests = {
#           cpu    = "100m"
#           memory = "256Mi"
#         }
#       }
#     })
#   ]
# }