output "sa_email" {
  value = google_service_account.this.email
}

output "sa_name" {
  value = google_service_account.this.name
}

output "role_id" {
  value = google_project_iam_custom_role.ecr-reader-role.id
}

output "role_name" {
  value = google_project_iam_custom_role.ecr-reader-role.name
}
