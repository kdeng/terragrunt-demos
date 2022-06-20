locals {
  instance_name = var.instance_name == "" || var.instance_name == null ? "${var.project_id}-gce" : var.instance_name

  public_ip_cidr_range    = var.enable_secondary_ip_alias ? cidrsubnet(var.public_seconday_subnet, 1, 0) : ""
  private_ip_cidr_range   = var.enable_secondary_ip_alias ? cidrsubnet(var.private_seconday_subnet, 1, 0) : ""

  public_seconday_subnet  = cidrsubnet(var.public_seconday_subnet, 7, 0)
  private_seconday_subnet  = cidrsubnet(var.private_seconday_subnet, 7, 0)

  secondary_count         = var.enable_secondary_ip_alias ? [1] : []
}

resource "google_service_account" "default" {
  provider      = google-beta
  project       = var.project_id
  account_id    = "gce-${var.env_region}-instance-sa"
  display_name  = "gce-${var.env_region}-instance-sa"
}

resource "google_compute_instance" "public_instance" {
  provider  = google-beta
  project   = var.project_id
  name      = "${local.instance_name}-public"
  zone      = var.project_zones[0]
  machine_type  = var.instance_type

  metadata_startup_script = var.metadata_startup_script

  tags            = [var.public_firewall_tag]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network       = var.network_id
    subnetwork    = var.public_subnet_id
    access_config {
      // Ephemeral public IP
    }

    dynamic "alias_ip_range" {
      for_each = local.secondary_count
      content {
        subnetwork_range_name = var.public_seconday_subnet_name
        ip_cidr_range  =  local.public_seconday_subnet
      }
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "private_instance" {
  provider  = google-beta
  project   = var.project_id
  name      = "${local.instance_name}-private"
  zone      = var.project_zones[0]

  machine_type  = var.instance_type
  metadata_startup_script = var.metadata_startup_script

  tags            = [var.private_firewall_tag]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network       = var.network_id
    subnetwork    = var.private_subnet_id
    // Comment out following code to disable external IP
    // access_config {
    //   // Ephemeral public IP
    // }
    dynamic "alias_ip_range" {
      for_each = local.secondary_count
      content {
        subnetwork_range_name = var.private_seconday_subnet_name
        ip_cidr_range  =  local.private_seconday_subnet
      }
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}
