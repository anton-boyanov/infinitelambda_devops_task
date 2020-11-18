# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../modules/aws/vpc"
}

# Include all settings from the root terragrunt.OLD file
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../../../tags",
  ]
}

dependency "tags" {
  config_path = "../../../tags"
}

locals {
  common_vars = merge(
  yamldecode(file("${find_in_parent_folders("application.yaml")}")),
  yamldecode(file("${find_in_parent_folders("awsRegion.yaml")}")),
  yamldecode(file("${find_in_parent_folders("account.yaml")}")),
  yamldecode(file("${find_in_parent_folders("vpc.yaml")}")),
  yamldecode(file("${find_in_parent_folders("environment.yaml")}")),
  )
}

inputs = {
  awsRegion = local.common_vars.awsRegion
  environment = local.common_vars.environment
  tags = dependency.tags.outputs.tags
}


