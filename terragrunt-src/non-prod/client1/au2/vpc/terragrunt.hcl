# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/.././/terraform-modules/vpc"
}

inputs = {
  project_cidr              = "10.1.0.0/16"
  enable_secondary_ip_alias = false
}
