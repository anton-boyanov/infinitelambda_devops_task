terraform {
  source = "../../../modules/aws/ecr_repos"
}

include {
  path = find_in_parent_folders()
}
locals {
  common_vars = merge(
  yamldecode(file("${find_in_parent_folders("application.yaml")}")),
  yamldecode(file("${find_in_parent_folders("account.yaml")}")),
  yamldecode(file("${find_in_parent_folders("awsRegion.yaml")}")),
  )
}
inputs = {
  awsRegion = local.common_vars.awsRegion
  application_name = local.common_vars.application_name
  names = local.common_vars.repo_names
}