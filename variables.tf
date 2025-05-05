variable "gcp_project_id" {
  type = string
  description = "The ID of your Google Cloud project."
  default     = "wideops-support-393412"
}

variable "gcp_region" {
  type        = string
  description = "The default GCP region to use for resources."
  default     = "europe-west1" # Choose a region suitable for you
}

variable "vpc_name" {
  type        = string
  description = "The name to use for the custom VPC network."
  default     = "my-custom-vpc"
}

variable "subnet_name" {
  type        = string
  description = "The name to use for the custom subnetwork."
  default     = "my-custom-subnet-1"
}

variable "subnet_ip_cidr_range" {
  type        = string
  description = "The IP CIDR range for the custom subnetwork."
  default     = "10.0.0.0/24"
}

variable "lb_ip" {
  type        = string
  description = "The the reserved ip for the load balancer"
  default     = "external-lb-ip"
}
# Optional: You can add more variables for other configurations later
