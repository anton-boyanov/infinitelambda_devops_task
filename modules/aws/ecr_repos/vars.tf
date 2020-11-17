variable "awsRegion" {}
variable "application_name" {}
variable "names" {
  description = "Name of the repo"
  type        = list(string)
  default     = [
    "hello"
  ]
}