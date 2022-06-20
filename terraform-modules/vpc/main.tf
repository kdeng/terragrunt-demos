data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.project_region
}

data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  network_name    = var.vpc_name == "" ? "${var.project_region}-vpc" : var.vpc_name
  max_zone_length = length(data.google_compute_zones.available.names)

  public_subnet   = cidrsubnet(var.project_cidr, 1, 0)
  private_subnet  = cidrsubnet(var.project_cidr, 1, 1)

  ifconfig_co_json = jsondecode(data.http.my_public_ip.body)

  secondary_count         = var.enable_secondary_ip_alias ? [1] : []
  public_seconday_subnet  = var.enable_secondary_ip_alias ? cidrsubnet(var.vpc_secondary_ip_cidr_range, 1, 0) : ""
  private_seconday_subnet = var.enable_secondary_ip_alias ? cidrsubnet(var.vpc_secondary_ip_cidr_range, 1, 1) : ""
  public_secondary_subnet_name    = "${var.public_subnet_name}-${var.env_region}-secondary-range"
  private_secondary_subnet_name   = "${var.private_subnet_name}-${var.env_region}-secondary-range"
}

resource "google_compute_firewall" "iap_firewall" {
  project   = var.project_id
  name      = "${local.network_name}-ingress-firewall-iap"
  network   = google_compute_network.this.name
  direction = "INGRESS"
  priority  = "1000"

  source_ranges   = ["35.235.240.0/20"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = [var.private_firewall_tag]
}

resource "google_compute_firewall" "public-server" {
  project   = var.project_id
  name      = "${local.network_name}-ingress-firewall-public-server"
  network   = google_compute_network.this.name
  direction = "INGRESS"
  priority  = "1000"

  source_ranges   = concat(["${local.ifconfig_co_json.ip}/32", var.project_cidr], var.peering_network_cidrs)

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_tags = [var.public_firewall_tag]

  depends_on  = [data.http.my_public_ip]
}

resource "google_compute_network" "this" {
  project       = var.project_id
  name          = local.network_name
  routing_mode  = var.routing_mode
  mtu           = var.vpc_network_mtu
  auto_create_subnetworks = var.auto_create_subnetworks
}

resource "google_compute_subnetwork" "this_public_subnet" {
  project       = var.project_id
  region        = var.project_region
  name          = var.public_subnet_name
  ip_cidr_range = local.public_subnet
  network       = google_compute_network.this.id

  # Follow best practice, always enable this to avoid the public IP is must
  private_ip_google_access  = true

  # Enable flow log
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  dynamic "secondary_ip_range" {
    for_each = local.secondary_count
    content {
      range_name    = local.public_secondary_subnet_name
      ip_cidr_range = local.public_seconday_subnet
    }
  }
}

resource "google_compute_subnetwork" "this_private_subnet" {
  project       = var.project_id
  region        = var.project_region
  name          = var.private_subnet_name
  network       = google_compute_network.this.id

  ip_cidr_range = local.private_subnet

  # Follow best practice, always enable this to avoid the public IP is must
  private_ip_google_access  = true

  # Enable flow log
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  dynamic "secondary_ip_range" {
    for_each = local.secondary_count
    content {
      range_name    = local.private_secondary_subnet_name
      ip_cidr_range = local.private_seconday_subnet
    }
  }
}

resource "google_compute_router" "router" {
  project = var.project_id
  region  = google_compute_subnetwork.this_private_subnet.region
  name    = "${local.network_name}-router"
  network = google_compute_network.this.id

  bgp {
    asn = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = []
    advertised_ip_ranges {
      range  = "0.0.0.0/0"
    }
  }
}

resource "google_compute_router_nat" "nat" {
  project       = var.project_id
  name          = "${local.network_name}-router-nat"
  router        = google_compute_router.router.name
  region        = google_compute_router.router.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.this_private_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
