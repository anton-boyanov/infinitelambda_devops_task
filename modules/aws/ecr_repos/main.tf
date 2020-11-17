provider "aws" {
  region = var.awsRegion
}
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
  required_version = "=0.12.16"
}

locals {

  lifecycle_policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 102,
      "description": "ECR image retention policy (untagged)",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

resource "aws_ecr_repository" "this" {
  count = length(var.names)
  name  = "${var.application_name}-${var.names[count.index]}-image"
}

resource "aws_ecr_lifecycle_policy" "this" {
  count = length(var.names)
  repository = "${var.application_name}-${var.names[count.index]}-image"
  policy     = local.lifecycle_policy

  depends_on = [aws_ecr_repository.this]
}
