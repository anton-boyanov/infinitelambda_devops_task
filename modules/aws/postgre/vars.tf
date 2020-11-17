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
//variable "domain" {}
//variable "zone_id" {}
//
//variable "vault_backend" {
//  default = "secret"
//}

# RDS
//variable "backup_retention_period" {}
//variable "engine" {}
//variable "engine_version" {}
//variable "skip_final_snapshot" {}
//variable "instance_class" {}
//variable "database_master_password" {}