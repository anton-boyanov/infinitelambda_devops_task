variable "account_id" {}
variable "awsRegion" {}
variable "environment" {}

variable "tags" {
  type    = map(string)
  default = {}
}