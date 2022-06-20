output "sa_email" {
  value = google_service_account.gke_node_sa.email
}

output "sa_name" {
  value = google_service_account.gke_node_sa.name
}

output "role_id" {
  value = google_project_iam_custom_role.ecr_reader_role.id
}

output "role_name" {
  value = google_project_iam_custom_role.ecr_reader_role.name
}

output "gke_id" {
  value = google_container_cluster.primary.id
}

output "gke_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "gke_master_version" {
  value = google_container_cluster.primary.master_version
}
