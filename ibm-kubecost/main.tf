resource "helm_release" "ibm_kubecost" {
  name       = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  version    = "2.4.3"  # Use a stable version before 2.9.x
  namespace  = "kubecost"
  create_namespace = true
  
  timeout       = 900  # 15 minutes timeout
  wait          = false  # Don't wait for pods to be ready
  wait_for_jobs = false
  # atomic        = true  # Removed to prevent auto-rollback for debugging

  values = [
    yamlencode({
      global = {
        clusterId = var.cluster_name
        prometheus = {
          enabled = true
        }
      }
      kubecostProductConfigs = {
        clusterName = var.cluster_name
      }
      # Disable ALL persistent volumes globally
      persistentVolume = {
        enabled = false
      }
      # Enable Prometheus with minimal resources
      prometheus = {
        server = {
          enabled = true
          persistentVolume = {
            enabled = false  # Disable persistent storage for demo
          }
          resources = {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
        nodeExporter = {
          enabled = true
          resources = {
            limits = {
              cpu    = "50m"
              memory = "64Mi"
            }
            requests = {
              cpu    = "25m"
              memory = "32Mi"
            }
          }
        }
        kubeStateMetrics = {
          enabled = true
          resources = {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }
        }
        alertmanager = {
          enabled = false  # Not needed for cost monitoring
        }
        pushgateway = {
          enabled = false  # Not needed for cost monitoring
        }
      }
      # Disable Grafana to save resources
      grafana = {
        enabled = false
      }
      # Set resource limits for cost-analyzer and disable its PV
      costAnalyzer = {
        persistentVolume = {
          enabled = false  # Disable persistent storage for cost-analyzer
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
      }
      # Explicitly disable kubecost-model PV
      kubecostModel = {
        persistentVolume = {
          enabled = false
        }
      }
    })
  ]
  
}