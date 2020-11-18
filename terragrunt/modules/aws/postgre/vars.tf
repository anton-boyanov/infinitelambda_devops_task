variable "account_id" {}
variable "awsRegion" {}
variable "application_name" {}
variable "environment" {}

variable "vpc_id" {}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "public_sg" {}

# RDS
variable "engine" {}
variable "engine_version" {}
variable "skip_final_snapshot" {}
variable "instance_class" {}