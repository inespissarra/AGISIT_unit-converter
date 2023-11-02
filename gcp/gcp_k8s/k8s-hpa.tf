# Terraform google cloud multi tier Kubernetes deployment

#################################################################
# Definition of the Horizontal Pod Autoscaler
#################################################################

resource "kubernetes_horizontal_pod_autoscaler_v1" "redis-follower-hpa" {
  metadata {
    name = "redis-follower-hpa"
    namespace = kubernetes_namespace.application.id
  }

  spec {
    max_replicas = 3
    min_replicas = 1
	  target_cpu_utilization_percentage = 80

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "redis-follower"
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v1" "datastore-hpa" {
  metadata {
    name = "datastore-hpa"
    namespace = kubernetes_namespace.application.id
  }

  spec {
    max_replicas = 3
    min_replicas = 1
	  target_cpu_utilization_percentage = 80

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "microservice-datastore"
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v1" "bin-dec-hpa" {
  metadata {
    name = "bin-dec-hpa"
    namespace = kubernetes_namespace.application.id
  }

  spec {
    max_replicas = 3
    min_replicas = 1
	  target_cpu_utilization_percentage = 80

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "microservice-bin-dec"
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v1" "temp-hpa" {
  metadata {
    name = "temp-hpa"
    namespace = kubernetes_namespace.application.id
  }

  spec {
    max_replicas = 3
    min_replicas = 1
	  target_cpu_utilization_percentage = 80

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "microservice-temp"
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v1" "frontend-hpa" {
  metadata {
    name = "frontend-hpa"
    namespace = kubernetes_namespace.application.id
  }

  spec {
    max_replicas = 3
    min_replicas = 1
	  target_cpu_utilization_percentage = 80

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "frontend"
    }
  }
}