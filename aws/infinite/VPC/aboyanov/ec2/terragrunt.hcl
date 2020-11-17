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
  )
}

terraform {
  source = "../../../../../modules/aws/create_ec2"
}

dependencies {
  paths = [
    "../tags",
    "../iam",
    "../network"
  ]
}

dependency "tags" {
  config_path = "../tags"
}

dependency "iam" {
  config_path = "../iam"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  #--------------- GLOGAL variables
  awsRegion = local.common_vars.awsRegion
  application_name = local.common_vars.application_name
  apm_ecr_url      = local.common_vars.apm_ecr_url
  tags = dependency.tags.outputs.tags
  key_name = local.common_vars.key_name

  #--------------- NETWORK variables
  vpc_id = dependency.network.outputs.vpc_id
  instance_sg = dependency.network.outputs.public_sg
  iam_instance_profile = dependency.iam.outputs.iam_instance_profile
  public_subnets = dependency.network.outputs.public_subnets
}