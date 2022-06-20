variable "project_id" {
  type = string
}

variable "env_region" {
  type = string
}

variable "project_region" {
  type = string
}

variable "project_zones" {
  type    = list(string)
  default = []
}

variable "project_cidr" {
  type    = string
}

variable "environment" {
  type    = string
  default = ""
}

variable "cluster_name" {
  type    = string
  default = ""
}

variable "cluster_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/16"
}

variable "services_ipv4_cidr_block" {
  type    = string
  default = "172.17.0.0/16"
}

variable "pod_ipv4_cidr_block" {
  type    = string
  default = "172.18.0.0/16"
}

variable "default_node_pool_machine_type" {
  type    = string
  default = "n1-standard-4"
}

variable "default_node_pool_preemptible" {
  type    = bool
  default = false
}

variable "default_node_pool_name" {
  type    = string
  default = "default-node-pool"
}

variable "default_node_pool_node_count" {
  type    = number
  default = 1
}

variable "default_node_pool_min_node_count" {
  type    = number
  default = 1
}

variable "default_node_pool_max_node_count" {
  type    = number
  default = 5
}

# https://tfsec.dev/docs/google/gke/no-legacy-auth/
variable "enable_client_certificates" {
  type    = bool
  default = true
}

### Network

variable "network_id" {
  type    = string
  default = ""
}

variable "public_subnet_id" {
  type    = string
  default = ""
}

variable "private_subnet_id" {
  type    = string
  default = ""
}

variable "private_subnet" {
  type    = string
  default = ""
}

variable "public_subnet" {
  type    = string
  default = ""
}
