# Terraform google cloud multi tier Kubernetes deployment
# Check how configure the provider here:
# https://www.terraform.io/docs/providers/google/index.html

provider "google" {
    # Create/Download your credentials from:
    # Google Console -> "APIs & services -> Credentials"
    credentials = file("./agisit-2324-project-05-e69a198b14a6.json")
}
