
#####################################################################
# the terraform.tfvars file
#####################################################################
# How to define variables in terraform:
# https://www.terraform.io/docs/configuration/variables.html

# Define the Project ID
project = "agisit-2324-project-05"

# Define the default number of Nodes for the cluster (1 per zone, 3 in total)
workers_count = "1"

# Define directory repo for docker images
gcr-repo = "proj-images"

# Define the Region/Zone
# Regions list is found at:
# https://cloud.google.com/compute/docs/regions-zones/regions-zones?hl=en_US
region = "europe-central2"

