output "cloudrun_id" {
  value = google_cloud_run_service.this.id
}

output "cloudrun_status" {
  value = google_cloud_run_service.this.status
}
