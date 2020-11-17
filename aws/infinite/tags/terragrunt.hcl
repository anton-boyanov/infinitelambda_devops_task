# Include all settings from the root terragrunt.OLD file
include {
  path = find_in_parent_folders()
}
locals {
  common_vars = merge(
  yamldecode(file("${find_in_parent_folders("application.yaml")}")),
  yamldecode(file("${find_in_parent_folders("awsRegion.yaml")}")),
  yamldecode(file("${find_in_parent_folders("account.yaml")}")),
  )
}

terraform {
  source = "../../../modules/aws/tags"
}

inputs = {
  awsRegion = local.common_vars.awsRegion
  application_name = local.common_vars.application_name
}