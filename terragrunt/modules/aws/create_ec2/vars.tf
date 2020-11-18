variable "awsRegion" {}
variable "application_name" {}

variable "vpc_id" {}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "instance_sg" {}
variable "key_name" {}
variable "iam_instance_profile" {}
variable "public_subnets" {
  type = list(string)
}
