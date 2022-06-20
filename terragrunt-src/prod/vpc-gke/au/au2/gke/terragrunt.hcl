# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]

  mock_outputs = {
    vpc_id              = "fake-vpc-id"
    public_subnet       = "fake-public-subnet"
    private_subnet      = "fake-private-subnet"
    project_cidr        = "fake-project-cidr"
    public_subnet_id    = "fake-public-subnet-id"
    private_subnet_id   = "fake-private-subnet-id"
    vpc_zones           = ["fake-vpc-zone"]
  }
}

terraform {
  source = "${path_relative_from_include()}/.././/terraform-modules/gke"
}

inputs = {
  project_zones       = dependency.vpc.outputs.vpc_zones
  project_cidr        = dependency.vpc.outputs.project_cidr
  network_id          = dependency.vpc.outputs.vpc_id
  public_subnet_id    = dependency.vpc.outputs.public_subnet_id
  private_subnet_id   = dependency.vpc.outputs.private_subnet_id
  public_subnet       = dependency.vpc.outputs.public_subnet
  private_subnet      = dependency.vpc.outputs.private_subnet
}

