variable "project_id" {
  type    = string
}

variable "project_region" {
  type    = string
}

variable "env_region" {
  type    = string
}

variable "vpc_name" {
  type    = string
  default = ""
}

variable "project_cidr" {
  type    = string
}

variable "enable_secondary_ip_alias" {
  type    = bool
  default = true
}

variable "vpc_secondary_ip_cidr_range" {
  type    = string
  default = "192.168.0.0/16"
}

variable "vpc_network_mtu" {
  type    = number
  default = 1460
}

variable "auto_create_subnetworks" {
  type    = bool
  default = false
}

variable "routing_mode" {
  // REGIONAL or GLOBAL
  type    = string
  default = "REGIONAL"
}

variable "private_subnet_name" {
  type    = string
  default = "private-subnet"
}

variable "public_subnet_name" {
  type    = string
  default = "public-subnet"
}

variable "private_firewall_tag" {
  type    = string
  default = "private-server"
}

variable "public_firewall_tag" {
  type    = string
  default = "public-server"
}

variable "peering_network_cidrs" {
  type    = list
  default = []
}
