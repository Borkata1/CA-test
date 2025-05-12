variable "gcp_project_id" {
  type        = string
  description = "The ID of your Google Cloud project."
}

variable "gcp_region" {
  type        = string
  description = "The default GCP region to use for resources."
}

variable "vpc_name" {
  type        = string
  description = "The name to use for the custom VPC network."
}

variable "subnet_name" {
  type        = string
  description = "The name to use for the custom subnetwork."
}

variable "subnet_ip_cidr_range" {
  type        = string
  description = "The IP CIDR range for the custom subnetwork."
}

variable "lb_ip" {
  type        = string
  description = "The reserved IP for the load balancer."
}
# Optional: You can add more variables for other configurations later
