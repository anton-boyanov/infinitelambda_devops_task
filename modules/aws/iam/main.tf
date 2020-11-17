terraform {
  backend "s3" {}
  required_version = "=0.12.16"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "e_ecs_instance_profile"
  role = aws_iam_role.ecs_instance_role.name
}
resource "aws_iam_role" "ecs_instance_role" {
  name               = "aboyanov_ecs_instance_role"
  assume_role_policy = data.template_file.ecs_instance_role.rendered
  tags = var.tags
}
data "template_file" "ecs_instance_role" {
  template = file("ecs_instance_role.tpl")
}
resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name   = "aboyanov_ecs_instance_role_policy"
  role   = aws_iam_role.ecs_instance_role.id
  policy = data.template_file.ecs_instance_role_policy.rendered
}
data "template_file" "ecs_instance_role_policy" {
  template = file("ecs_instance_role_policy.tpl")
}
