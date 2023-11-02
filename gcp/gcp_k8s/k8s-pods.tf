# Terraform google cloud multi tier Kubernetes deployment

#################################################################
# Definition of the Pods
#################################################################

#################################################################
# Defined the Microservices Pods for the Unit Converter
#################################################################
# The Backend Pods for Data Store deployment with REDIS
# see: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/replication_controller

# Defines 1 REDIS Leader (not replicated)
resource "kubernetes_stateful_set" "redis-leader" {
  metadata {
    name = "redis-leader"
    labels = {
      app  = "unit-converter"
      role = "redis-leader"
      tier = "backend"
    }
    namespace = kubernetes_namespace.application.id
  }

  spec {
    # progress_deadline_seconds = 1200 # In case of taking longer than 9 minutes
    replicas = 1
    service_name = "redis-leader"
    selector {
      match_labels = {
        app  = "unit-converter"
        role = "redis-leader"
        tier = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app  = "unit-converter"
          role = "redis-leader"
          tier = "backend"
        }
      }
      spec {
        container {
          image = "docker.io/redis:6.0.5"
          name  = "leader"

          port {
            container_port = 6379
          }

          volume_mount {
            name       = "redis-volume"
            mount_path = "/data"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "redis-volume"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "16Gi"
          }
        }
      }
    }
  }
  depends_on = [
    helm_release.istiod,
    kubernetes_namespace.application
  ]
}
# Defines 1 REDIS Follower
resource "kubernetes_deployment" "redis-follower" {
  metadata {
    name = "redis-follower"

    labels = {
      app  = "unit-converter"
      role = "redis-follower"
      tier = "backend"
    }
    namespace = kubernetes_namespace.application.id
  }

  spec {
    progress_deadline_seconds = 1200 # In case of taking longer than 9 minutes
    replicas = 1
    selector {
      match_labels = {
        app  = "unit-converter"
        role = "redis-follower"
        tier = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app  = "unit-converter"
          role = "redis-follower"
          tier = "backend"
        }
      }
      spec {
        container {
          image = "gcr.io/google_samples/gb-redis-follower:v2"
          name  = "follower"

          port {
            container_port = 6379
          }

          env {
            name  = "GET_HOSTS_FROM"
            value = "dns"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }
  depends_on = [
    helm_release.istiod,
    kubernetes_namespace.application
  ]
}
# Defines 1 Datastore Microservice
resource "kubernetes_deployment" "microservice-datastore" {
  metadata {
    name = "microservice-datastore"
    labels = {
      app  = "unit-converter"
      role = "datastore"
      tier = "backend"
    }
    namespace = kubernetes_namespace.application.id
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app  = "unit-converter"
        role = "datastore"
        tier = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app  = "unit-converter"
          role = "datastore"
          tier = "backend"
        }
      }

      spec {
        container {
          image = "gcr.io/${var.project}/${var.gcr-repo}/datastore:v0.0.1"
          image_pull_policy = "Always"
          name  = "datastore"

          port {
            container_port = 8003
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }
  depends_on = [
    docker_registry_image.datastore-image,
    helm_release.istiod,
    kubernetes_namespace.application]
}
# Defines 1 Binary/Decimal Microservice
resource "kubernetes_deployment" "microservice-bin-dec" {
  metadata {
    name = "microservice-bin-dec"
    labels = {
      app = "unit-converter"
      role = "bin-dec-converter"
      tier = "backend"
    }
    namespace = kubernetes_namespace.application.id
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "unit-converter"
        role = "bin-dec-converter"
        tier = "backend"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "unit-converter"
          role = "bin-dec-converter"
          tier = "backend"
        }
      }

      spec {
        container {
          image = "gcr.io/${var.project}/${var.gcr-repo}/bindec:v0.0.1"
          image_pull_policy = "Always"
          name  = "bindec"

          port {
            container_port = 8001
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }
  depends_on = [
    docker_registry_image.bin-dec-image,
    helm_release.istiod,
    kubernetes_namespace.application]
}
# Defines 1 Temperature Microservice
resource "kubernetes_deployment" "microservice-temp" {
  metadata {
    name = "microservice-temp"
    labels = {
      app  = "unit-converter"
      role = "temp-converter"
      tier = "backend"
    }
    namespace = kubernetes_namespace.application.id
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app  = "unit-converter"
        role = "temp-converter"
        tier = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app  = "unit-converter"
          role = "temp-converter"
          tier = "backend"
        }
      }

      spec {
        container {
          image = "gcr.io/${var.project}/${var.gcr-repo}/temp:v0.0.1"
          image_pull_policy = "Always"
          name  = "temp"

          port {
            container_port = 8002
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }
  depends_on = [
    docker_registry_image.temp-image,
    helm_release.istiod,
    kubernetes_namespace.application]
}


#################################################################
# Defined the Frontend Pods for the Unit Converter
#################################################################
resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
    labels = {
      app  = "unit-converter"
      tier = "frontend"
    }
    namespace = kubernetes_namespace.application.id
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app  = "unit-converter"
        tier = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app  = "unit-converter"
          tier = "frontend"
        }
      }

      spec {
        container {
          image = "gcr.io/${var.project}/${var.gcr-repo}/frontend:v0.0.1"
          image_pull_policy = "Always"
          name  = "frontend"

          port {
            container_port = 8000
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }
  depends_on = [
    docker_registry_image.frontend-image,
    helm_release.istiod,
    kubernetes_namespace.application]
}
