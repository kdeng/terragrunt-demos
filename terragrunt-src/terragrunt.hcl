# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load project-level variables
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  # Automatically load envrionment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  # Automatically load regional-level variables
  regional_vars = read_terragrunt_config(find_in_parent_folders("regional.hcl"))

  # Extract the variables we need for easy access
  project_id     = local.project_vars.locals.project_id
  project_region = local.regional_vars.locals.project_region
  environment    = local.environment_vars.locals.environment
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.0.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.1.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.6.1"
    }
    http = {
      source = "hashicorp/http"
      version = "2.1.0"
    }
  }
}

provider "google-beta" {
  region = "${local.project_region}"
  project = "${local.project_id}"
}

provider "null" {
}

provider "http" {
}

EOF
}

// remote_state {
//   backend = "local"
//   config = {
//       path = "./terraform.tfstate"
//   }
// }

# Configure Terragrunt to automatically store tfstate files in a remote bucket
// remote_state {
//   backend = "gcs"
//   config = {
//     project         = local.project_id
//     location        = local.project_region
//     bucket          = "terragrunt-terraform-state"
//     prefix          = "${local.project_id}-${local.environment}/terraform.tfstate"

//     credentials = "${get_terragrunt_dir()}/${find_in_parent_folders("credentials.json")}"

//     // skip_bucket_creation    = false
//     skip_bucket_versioning  = true # use only if the object store does not support versioning
//     enable_bucket_policy_only = false # use only if uniform bucket-level access is needed (https://cloud.google.com/storage/docs/uniform-bucket-level-access)
//     encryption_key = "GOOGLE_ENCRYPTION_KEY"
//   }
//   generate = {
//     path      = "backend.tf"
//     if_exists = "overwrite_terragrunt"
//   }
// }


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.project_vars.locals,
  local.environment_vars.locals,
  local.regional_vars.locals,
)
