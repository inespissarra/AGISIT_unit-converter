# Terraform google cloud multi tier Kubernetes deployment
# Create 2 namespaces
# Namespace for Isito Service Mesh, Prometheus and Grafana
resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

# Namespace for the application pods and services
resource "kubernetes_namespace" "application" {
  metadata {
    name = "application"
   
    labels = {
      istio-injection = "enabled"
    }
  }
}