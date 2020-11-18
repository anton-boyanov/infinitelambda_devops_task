provider "aws" {
  region = var.awsRegion
}
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
  required_version = "0.12.16"
}


locals {
  tag_names = {
    project = "project"
    cost_center = "cost_center"
    owner = "owner"
    car_id = "car_id"
    confidentiality = "confidentiality"
    assignment_group = "assignment_group"
    environment = "Environment"
    application = "Application"
    creator = "Creator"
    date_updated = "Date Updated"
  }

  tags = {
    "${local.tag_names["project"]}" = var.project
    "${local.tag_names["cost_center"]}" = var.cost_center
    "${local.tag_names["owner"]}" = var.owner
    "${local.tag_names["car_id"]}" = var.car_id
    "${local.tag_names["confidentiality"]}" = var.confidentiality
    "${local.tag_names["assignment_group"]}" = var.assignment_group
    "${local.tag_names["application"]}" = var.application_name
    "${local.tag_names["environment"]}" = var.environment
    "${local.tag_names["creator"]}" = "${var.application_name}-terraform"
    "${local.tag_names["date_updated"]}" = timestamp()
  }
}