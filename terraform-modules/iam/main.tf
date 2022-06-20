resource "google_project_iam_custom_role" "ecr-reader-role" {
  provider      = google-beta
  project       = var.project_id
  role_id     = "container_registry_reader"
  title       = "container-registry-reader"
  description = "Container Registry Reader"
  permissions = [
    "storage.objects.get",
    "storage.objects.getIamPolicy",
    "storage.objects.list"
  ]
}

resource "google_service_account" "this" {
  provider      = google-beta
  project       = var.project_id
  account_id    = var.service_account_name
  display_name  = var.service_account_display_name
}

resource "google_service_account_iam_binding" "ecr-reader-binding" {
  service_account_id = google_service_account.this.name
  role               = google_project_iam_custom_role.ecr-reader-role.id

  members = [
    "serviceAccount:${google_service_account.this.email}",
  ]

  depends_on = [
    google_project_iam_custom_role.ecr-reader-role,
    google_service_account.this
  ]
}

resource "google_project_iam_member" "project" {
  provider      = google-beta
  project       = var.project_id

  role    = google_project_iam_custom_role.ecr-reader-role.id
  member  = "serviceAccount:${google_service_account.this.email}"
}
