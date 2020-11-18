terraform {
  source = "../../../../../modules/aws/postgre"
}

dependencies {
  paths = [
    "../network",
    "../../../tags"
  ]
}

dependency "network" {
  config_path = "../network"
}
dependency "tags" {
  config_path = "../../../tags"
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

inputs = {
  awsRegion = local.common_vars.awsRegion
  environment = local.common_vars.environment
  application_name = local.common_vars.application_name
  account_id = local.common_vars.account_id
  vpc_id = dependency.network.outputs.vpc_id
  public_sg = dependency.network.outputs.public_sg

  engine = local.common_vars.engine
  engine_version = local.common_vars.engine_version
  skip_final_snapshot = local.common_vars.skip_final_snapshot
  instance_class = local.common_vars.instance_class

}
