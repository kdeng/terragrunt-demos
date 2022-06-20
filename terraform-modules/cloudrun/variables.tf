variable "project_id" {
  type = string
}

variable "env_region" {
  type    = string
}

variable "project_region" {
  type    = string
}

variable "environment" {
  type    = string
  default = ""
}

variable "service_name" {
  type    = string
  default = ""
}

variable "container_image" {
  type = string
  default = "gcr.io/kefeng-playground/api-demo:node-v1"
}

variable "traffic_percent" {
  type    = number
  default = 100
}

variable "min_instance" {
  type    = string
  default = "2"
}

variable "max_instance" {
  type    = string
  default = "5"
}
