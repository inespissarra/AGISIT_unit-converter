# Terraform google cloud multi tier Kubernetes deployment

#################################################################
# Definition of the Services
#################################################################

#################################################################
# The Services for the Microservices Pods
#################################################################
# The Service for the REDIS Leader Pods
resource "kubernetes_service" "redis-leader" {
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
    selector = {
      app  = "unit-converter"
      role = "redis-leader"
      tier = "backend"
    }

    port {
      port = 6379
      target_port = 6379
    }
  }
}

# The Service for the REDIS Follower Pods
resource "kubernetes_service" "redis-follower" {
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
    selector = {
      app  = "unit-converter"
      role = "redis-follower"
      tier = "backend"
    }

    port {
      port = 6379
    }
  }
}

# The Service for the Datastore Pods
resource "kubernetes_service" "microservice-datastore" {
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
    selector = {
      app  = "unit-converter"
      role = "datastore"
      tier = "backend"
    }

    port {
      port = 8003
    }
  }
}


# The Service for the Binary/Decimal converter Pods
resource "kubernetes_service" "microservice-bin-dec" {
  metadata {
    name = "microservice-bin-dec"

    labels = {
      app  = "unit-converter"
      role = "bin-dec-converter"
      tier = "backend"
    }

    namespace = kubernetes_namespace.application.id
  }

  spec {
    selector = {
      app  = "unit-converter"
      role = "bin-dec-converter"
      tier = "backend"
    }

    port {
      port = 8001
    }
  }
}

# The Service for the Temperature converter Pods
resource "kubernetes_service" "microservice-temp" {
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
    selector = {
      app  = "unit-converter"
      role = "temp-converter"
      tier = "backend"
    }

    port {
      port = 8002
    }
  }
}

#################################################################
# The Service for the Frontend Load Balancer Ingress
#################################################################
resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"

    labels = {
      app  = "unit-converter"
      tier = "frontend"
    }

    namespace = kubernetes_namespace.application.id
  }

  spec {
    selector = {
      app  = "unit-converter"
      tier = "frontend"
    }

    type = "LoadBalancer"

    port {
      port = 80
      target_port = 8000
    }
  }
}
