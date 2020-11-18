terraform {
  source = "../../../../../modules/aws/s3"
}

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

dependencies {
  paths = [
    "../../../tags"
  ]
}

dependency "tags" {
  config_path = "../../../tags"
}


inputs = {
  account_id = local.common_vars.account_id
  awsRegion = local.common_vars.awsRegion
  environment = local.common_vars.environment
  tags = dependency.tags.outputs.tags
}

