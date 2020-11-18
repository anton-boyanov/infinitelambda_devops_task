provider "aws" {
  region = var.awsRegion
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
  required_version = "0.12.16"
}

#-------------------------------------------------- Create S3 Bucket

resource "aws_s3_bucket" "this" {
  bucket = "${var.account_id}-${var.environment}-s3-hello-website"
  acl    = "public-read"
  tags = var.tags
  policy = file("policy.json")

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
}
