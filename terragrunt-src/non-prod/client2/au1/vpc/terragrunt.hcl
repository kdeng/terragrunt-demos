locals {
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/.././/terraform-modules/vpc"

#  extra_arguments "load_global_variables" {
#    commands = get_terraform_commands_that_need_vars()
#    optional_var_files = ["${get_parent_terragrunt_dir()}/terraform.tfvars"]
#  }
}

inputs = {
  project_cidr                = "10.0.0.0/16"
  vpc_secondary_ip_cidr_range = "192.168.0.0/16"

}
