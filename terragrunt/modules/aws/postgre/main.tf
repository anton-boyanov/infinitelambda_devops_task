provider "aws" {
  region = var.awsRegion
}
terraform {
  backend "s3" {}
  required_version = "=0.12.16"
}

data "aws_ssm_parameter" "pass" {
  name = "/aboyanov/database/password/master"
}
data "aws_ssm_parameter" "user" {
  name = "/aboyanov/database/username/master"
}


data "aws_subnet_ids" "app_subnet_ids" {
  vpc_id = var.vpc_id
  tags = merge(var.tags, {
    Class = "APP"
  })
}

data "aws_subnet" "app_subnets" {
  count = length(data.aws_subnet_ids.app_subnet_ids.ids)
  id = tolist(data.aws_subnet_ids.app_subnet_ids.ids)[count.index]
  vpc_id = var.vpc_id
  tags = merge(var.tags, {
    Class = "APP"
  })
}

resource "aws_db_subnet_group" "private" {
  name       = "private"
  subnet_ids = data.aws_subnet_ids.app_subnet_ids.ids

  tags = merge(var.tags, {
    Name = "My DB subnet group"
  })
}

#----------------------------------------------------------------------------- PostgreSQL RDS
resource "aws_db_instance" "this" {
  identifier           = "aboyanov"
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  name                 = "mydb"
  username             = data.aws_ssm_parameter.user.value
  password             = data.aws_ssm_parameter.pass.value
  db_subnet_group_name = aws_db_subnet_group.private.name
  skip_final_snapshot = var.skip_final_snapshot
  tags = var.tags
  depends_on = [data.aws_ssm_parameter.user, data.aws_ssm_parameter.pass]
}

