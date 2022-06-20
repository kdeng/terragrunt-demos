output "vpc_id" {
  value = google_compute_network.this.id
}

output "project_cidr" {
  value = var.project_cidr
}

output "public_subnet" {
  value = local.public_subnet
}

output "private_subnet" {
  value = local.private_subnet
}

output "public_subnet_id" {
  value = google_compute_subnetwork.this_public_subnet.id
}

output "private_subnet_id" {
  value = google_compute_subnetwork.this_private_subnet.id
}

output "vpc_zones" {
  value = data.google_compute_zones.available.names
}

output "myip" {
  value = local.ifconfig_co_json.ip
}

output "public_seconday_subnet" {
  value = local.public_seconday_subnet
}

output "private_seconday_subnet" {
  value = local.private_seconday_subnet
}

output "public_seconday_subnet_name" {
  value = local.public_secondary_subnet_name
}

output "private_seconday_subnet_name" {
  value = local.private_secondary_subnet_name
}

output "public_firewall_tag" {
  value = var.public_firewall_tag
}

output "private_firewall_tag" {
  value = var.private_firewall_tag
}
