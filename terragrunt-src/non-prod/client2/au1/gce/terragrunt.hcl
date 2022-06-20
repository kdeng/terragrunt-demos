locals {
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]

  mock_outputs = {
    vpc_id              = "fake-vpc-id"
    public_subnet       = "10.0.128.0/17"
    private_subnet      = "10.0.0.0/17"
    project_cidr        = "10.0.0.0/16"
    public_subnet_id    = "fake-public-subnet-id"
    private_subnet_id   = "fake-private-subnet-id"
    vpc_zones           = ["fake-vpc-zone1"]
    public_seconday_subnet    = "192.168.0.0/24"
    private_seconday_subnet   = "192.168.1.0/24"
    public_seconday_subnet_name   = "fake-public-subnet-name"
    private_seconday_subnet_name  = "fake-private-subnet-name"
    public_firewall_tag   = "public-server"
    private_firewall_tag  = "private-server"
  }
}

terraform {
  source = "${path_relative_from_include()}/.././/terraform-modules/gce"
}

inputs = {
  project_zones       = dependency.vpc.outputs.vpc_zones
  project_cidr        = dependency.vpc.outputs.project_cidr
  network_id          = dependency.vpc.outputs.vpc_id
  public_subnet_id    = dependency.vpc.outputs.public_subnet_id
  private_subnet_id   = dependency.vpc.outputs.private_subnet_id
  public_subnet       = dependency.vpc.outputs.public_subnet
  private_subnet      = dependency.vpc.outputs.private_subnet

  public_seconday_subnet_name     = dependency.vpc.outputs.public_seconday_subnet_name
  public_seconday_subnet          = dependency.vpc.outputs.public_seconday_subnet
  private_seconday_subnet_name    = dependency.vpc.outputs.private_seconday_subnet_name
  private_seconday_subnet         = dependency.vpc.outputs.private_seconday_subnet

  public_firewall_tag     = dependency.vpc.outputs.public_firewall_tag
  private_firewall_tag    = dependency.vpc.outputs.private_firewall_tag
}

