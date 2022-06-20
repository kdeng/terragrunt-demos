locals {
  gke_cluster_name = var.cluster_name == "" || var.cluster_name == null ? "${var.project_id}-${var.env_region}-gke-cluster" : var.cluster_name
  default_node_pool_name = var.default_node_pool_name == "" || var.default_node_pool_name == null ? "default-node-pool" : var.default_node_pool_name

  gke_node_sa_id  = "gke-${var.env_region}-node-sa"
}

resource "random_id" "role_id" {
  byte_length = 4
}

resource "google_project_iam_custom_role" "ecr_reader_role" {
  provider      = google-beta
  project       = var.project_id

  role_id     = "container_registry_reader_${random_id.role_id.hex}"
  title       = "container-registry-reader-${random_id.role_id.hex}"
  description = "Container Registry Reader (${random_id.role_id.hex})"
  permissions = [
    "storage.objects.get",
    "storage.objects.getIamPolicy",
    "storage.objects.list"
  ]
}

resource "google_service_account" "gke_node_sa" {
  provider      = google-beta
  project       = var.project_id

  account_id    = local.gke_node_sa_id
  display_name  = local.gke_node_sa_id
}

// resource "google_service_account_iam_binding" "ecr_reader_binding" {

//   service_account_id = google_service_account.gke_node_sa.name
//   role               = google_project_iam_custom_role.ecr_reader_role.id

//   members = [
//     "serviceAccount:${google_service_account.gke_node_sa.email}",
//   ]

//   depends_on = [
//     google_project_iam_custom_role.ecr_reader_role,
//     google_service_account.gke_node_sa
//   ]
// }

resource "google_project_iam_member" "project" {
  provider      = google-beta
  project       = var.project_id

  role    = google_project_iam_custom_role.ecr_reader_role.id
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}

resource "google_container_cluster" "primary" {
  provider  = google-beta
  project   = var.project_id
  name      = local.gke_cluster_name
  location        = var.project_region
  node_locations  = var.project_zones

  network         = var.network_id
  subnetwork      = var.private_subnet_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  ### Network
  networking_mode     = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_ipv4_cidr_block       = var.cluster_ipv4_cidr_block
    services_ipv4_cidr_block      = var.services_ipv4_cidr_block
  }

  addons_config {
    http_load_balancing {
      // enable this feature to support BackendConfig
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  cluster_autoscaling {
    enabled             = true
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    resource_limits {
      resource_type = "cpu"
      minimum = 0
      maximum = 8
    }
    resource_limits {
      resource_type = "memory"
      minimum = 0
      maximum = 64
    }
    auto_provisioning_defaults {
      service_account = google_service_account.gke_node_sa.email
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }

  ### Enable workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ### Maintenance policy
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  # https://tfsec.dev/docs/google/gke/no-legacy-auth/
  master_auth {
    client_certificate_config {
      issue_client_certificate = var.enable_client_certificates
    }
  }
}

resource "google_container_node_pool" "primary_node_pool" {
  provider    = google-beta
  project     = var.project_id
  name        = local.default_node_pool_name
  location        = var.project_region
  node_locations  = var.project_zones

  cluster         = google_container_cluster.primary.name
  node_count  = 1

  autoscaling {
    min_node_count    = var.default_node_pool_min_node_count
    max_node_count    = var.default_node_pool_max_node_count
  }

  node_config {
    preemptible  = var.default_node_pool_preemptible
    machine_type = var.default_node_pool_machine_type
    metadata = {
      disable-legacy-endpoints = "true"
    }
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke_node_sa.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }

  network_config {
    create_pod_range      = "true"
    pod_ipv4_cidr_block   = var.pod_ipv4_cidr_block
    pod_range             = "${local.default_node_pool_name}-pod-range"
  }

}

data "google_container_cluster" "cluster" {
  project   = var.project_id
  name      = local.gke_cluster_name
  location  = var.project_region
}

data "google_client_config" "provider" {}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.cluster.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
}

// resource "null_resource" "gpu-driver" {

//   depends_on = [
//     google_container_cluster.primary
//   ]

//   provisioner "local-exec" {
//     command = "gcloud container clusters get-credentials --region=${var.project_region} ${local.gke_cluster_name}"
//   }

//   provisioner "local-exec" {
//     command    = "kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded.yaml"
//   }

// }
