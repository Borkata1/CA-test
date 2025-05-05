terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Specify a version constraint
    }
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region       # Choose your desired default region
  # zone        = "europe-west1-b"     # Optional: Choose a default zone
  credentials = file("/home/boris_k/new-wideops-support-key.json")
}
