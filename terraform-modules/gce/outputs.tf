output "sa_email" {
  value = google_service_account.default.email
}

output "private_instance_id" {
  value = google_compute_instance.private_instance.instance_id
}

output "public_instance_id" {
  value = google_compute_instance.public_instance.instance_id
}

output "public_ip_cidr_range" {
  value = local.public_ip_cidr_range
}

output "private_ip_cidr_range" {
  value = local.private_ip_cidr_range
}
