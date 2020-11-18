provider "aws" {
  region = var.awsRegion
}
terraform {

  backend "s3" {}
  required_version = "=0.12.16"
}

##############################################################

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

}

resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  subnet_id = var.public_subnets[0]
  security_groups = [var.instance_sg]
  key_name = var.key_name
  iam_instance_profile = var.iam_instance_profile
  user_data = data.template_file.user_data.rendered

  tags = merge(var.tags, {
    Name = "aboyanov_Jenkins"
  })
}