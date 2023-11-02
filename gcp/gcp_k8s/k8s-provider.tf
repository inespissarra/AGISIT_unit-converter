# Terraform google cloud multi tier Kubernetes deployment

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
data "google_client_config" "default" {
}

provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address = "gcr.io"
    username = "oauth2accesstoken"
    password = data.google_client_config.default.access_token
  }
}

provider "helm" {
  kubernetes {
    host = "https://${var.host}"

    token                  = data.google_client_config.default.access_token
    client_certificate     = base64decode(var.client_certificate)
    client_key             = base64decode(var.client_key)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = "https://${var.host}"
  load_config_file       = false

  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "kubernetes" {

  host = "https://${var.host}"

  token                  = data.google_client_config.default.access_token
  client_certificate     = base64decode(var.client_certificate)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}