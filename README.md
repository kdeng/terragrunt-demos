# Terragrunt Demo

This repository contains a terragrunt demo to manage multiple projects with multiple enviornments in a single repository.

## How to deploy the infrastructure in this repo?

### Pre-requistes

1. Install Terraform
2. Install Terragrunt
3. Configure your GCP credentials properly

### Deploying a single module

1. `cd` into the module's folder (e.g. `cd non-prod/client2/au1/vpc`)
2. Run `terragrunt run-all plan`
3. If the plan looks good, run `terragrunt run-all apply`

### Deploying all modules of a single client

1. `cd` into the client's folder (e.g. `cd non-prod/client2`)
2. Run `terragrunt run-all plan`
3. If the plan looks good, run `terragrunt run-all apply`

### Deploying all modules of an environment

1. `cd` into the environment's folder (e.g. `cd prod`)
2. Run `terragrunt run-all plan`
3. If the plan looks good, run `terragrunt run-all apply`
