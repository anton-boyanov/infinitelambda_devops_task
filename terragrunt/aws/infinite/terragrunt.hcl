remote_state {
  backend = "s3"

  config = {
    encrypt = true
    bucket = "aboyanov-eu-west-1-terragrunt"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "aboyanov-terragrunt-locks"
    s3_bucket_tags = {
      owner = "terragrunt integration"
      name = "Terraform state storage"
      project = "aboyanov"
    }

    dynamodb_table_tags = {
      owner = "terragrunt integration"
      name = "Terraform lock table"
      project = "aboyanov"
    }
  }
}