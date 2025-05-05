
resource "google_compute_network" "custom_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = var.subnet_name
  region        = var.gcp_region
  network       = google_compute_network.custom_vpc.name
  ip_cidr_range = var.subnet_ip_cidr_range
}

resource "google_compute_firewall" "allow_ssh_http" {
  name    = "allow-ssh-http"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
}

resource "google_compute_instance" "web_test_vm" {
  name         = "vm-instance"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20240709"
    }
  }

  network_interface {
    network    = google_compute_network.custom_vpc.self_link
    subnetwork = google_compute_subnetwork.subnet_1.self_link
    access_config {}
  }

  metadata = {
    startup-script = <<EOT
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    echo "This is my test web server!" > /var/www/html/index.html
    mkdir -p /var/www/html/.secret
    echo "Secret File!" > /var/www/html/.secret/file1.txt
    EOT
  }

  tags = ["web", "server"]
}

resource "google_compute_health_check" "tcp_health_check" {
  name               = "tcp-health-check"
  timeout_sec        = 5
  check_interval_sec = 10

  tcp_health_check {
    port = 80
  }
}

# 2. Create Unmanaged Instance Group
resource "google_compute_instance_group" "web_instance_group" {
  name    = "web-instance-group"
  network = google_compute_network.custom_vpc.self_link
  zone    = "europe-west1-b"
}

# 3. Add the VM to the Unmanaged Instance Group
resource "google_compute_instance_group_membership" "web_instance_group_membership" {
  instance_group = google_compute_instance_group.web_instance_group.name
  instance       = google_compute_instance.web_test_vm.self_link
  zone           = "europe-west1-b"
}

# 4. Create Backend Service and use the Instance Group
resource "google_compute_backend_service" "backend_service" {
  name          = "web-backend"
  protocol      = "HTTP"
  health_checks = [google_compute_health_check.tcp_health_check.self_link]

  backend {
    group            = google_compute_instance_group.web_instance_group.self_link
    balancing_mode   = "UTILIZATION"
    max_utilization  = 0.8
  }
}

# 5. Set up the URL map
resource "google_compute_url_map" "web_map" {
  name            = "web-map"
  default_service = google_compute_backend_service.backend_service.self_link
}

# 6. Configure Target HTTP Proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "web-http-proxy"
  url_map = google_compute_url_map.web_map.self_link
}

# **Insert the global IP address resource here (before the forwarding rule)**
resource "google_compute_global_address" "lb_global_ip" {
  project      = var.gcp_project_id
  name         = var.lb_ip       # Unique name for your global IP address
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

# 7. Create Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "lb_forwarding_rule" {
  name       = "web-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.self_link
  ip_address = google_compute_global_address.lb_global_ip.address # Reference the created global IP
  port_range = "80"
}

# Output the Load Balancer IP
output "lb_ip" {
  value = google_compute_global_address.lb_global_ip.address # Reference the created global IP
  description = "The global static IP address reserved for the external load balancer."
}
