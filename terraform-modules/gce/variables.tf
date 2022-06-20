variable "project_id" {
  type = string
}

variable "project_region" {
  type = string
}

variable "env_region" {
  type    = string
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

variable "instance_name" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = "e2-micro"
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

variable "public_seconday_subnet" {
  type    = string
  default = ""
}

variable "private_seconday_subnet" {
  type    = string
  default = ""
}

variable "public_seconday_subnet_name" {
  type    = string
  default = ""
}

variable "private_seconday_subnet_name" {
  type    = string
  default = ""
}

variable "public_firewall_tag" {
  type    = string
  default = ""
}

variable "private_firewall_tag" {
  type    = string
  default = ""
}

variable "enable_secondary_ip_alias" {
  type    = bool
  default = true
}

variable "metadata_startup_script" {
  type    = string
  default = <<EOF
#!/bin/bash
apt update && apt install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF
}
