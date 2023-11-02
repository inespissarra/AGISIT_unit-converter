#################################################################
# Builds and pushes Docker images to a Google Cloud Repository
#################################################################

variable "gcr-repo" {
    type = string
}

variable "project" {
    type = string
}

resource "docker_image" "datastore-image" {
  name = "gcr.io/${var.project}/${var.gcr-repo}/datastore:v0.0.1"
  build {
    context = "/home/vagrant/backend/datastore"
  }
}

resource "docker_registry_image" "datastore-image" {
  name = docker_image.datastore-image.name
}

resource "docker_image" "bin-dec-image" {
  name = "gcr.io/${var.project}/${var.gcr-repo}/bindec:v0.0.1"
  build {
    context = "/home/vagrant/backend/bindec"
  }
}

resource "docker_registry_image" "bin-dec-image" {
  name = docker_image.bin-dec-image.name
}

resource "docker_image" "temp-image" {
  name = "gcr.io/${var.project}/${var.gcr-repo}/temp:v0.0.1"
  build {
    context = "/home/vagrant/backend/temp"
  }
}

resource "docker_registry_image" "temp-image" {
  name = docker_image.temp-image.name
}

resource "docker_image" "frontend-image" {
  name = "gcr.io/${var.project}/${var.gcr-repo}/frontend:v0.0.1"
  build {
    context = "/home/vagrant/frontend"
  }
}

resource "docker_registry_image" "frontend-image" {
  name = docker_image.frontend-image.name
}