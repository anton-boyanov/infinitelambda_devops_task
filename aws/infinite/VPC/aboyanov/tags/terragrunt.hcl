# Include all settings from the root terragrunt.OLD file
include {
  path = find_in_parent_folders()
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

terraform {
  source = "../../../../../modules/aws/tags"
}

inputs = {
  awsRegion = local.common_vars.awsRegion
  environment = local.common_vars.environment
  application_name = local.common_vars.application_name
  build_tag = "${get_env("BUILD_TAG", "Jenkins Build")}"
}