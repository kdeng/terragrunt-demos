locals {
  cloudrun_service_name = "${var.service_name}-${var.env_region}"
}

resource "google_cloud_run_service" "this" {
  provider      = google-beta
  project       = var.project_id
  name          = local.cloudrun_service_name
  location      = var.project_region

  template {
    spec {
      containers {
        image = var.container_image
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"      = var.min_instance
        "autoscaling.knative.dev/maxScale"      = var.max_instance
        "run.googleapis.com/client-name"        = "terraform"
      }
    }
  }

  autogenerate_revision_name = true

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.this.location
  project     = google_cloud_run_service.this.project
  service     = google_cloud_run_service.this.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
