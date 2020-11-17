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
  tags = {
    Class = "APP"
  }
}

data "aws_subnet" "app_subnets" {
  count = length(data.aws_subnet_ids.app_subnet_ids.ids)
  id = tolist(data.aws_subnet_ids.app_subnet_ids.ids)[count.index]
  vpc_id = var.vpc_id
  tags = {
    Class = "APP"
  }
}

resource "aws_db_subnet_group" "private" {
  name       = "private"
  subnet_ids = data.aws_subnet_ids.app_subnet_ids.ids

  tags = {
    Name = "My DB subnet group"
  }
}

//#---PRIVATE SG
//
//resource "aws_db_security_group" "private_sg" {
//  name        = "aboyanov_private_sg"
//  description = "Used to put MySql instances"
//
//  tags = merge(var.tags, {
//    Name = "aboyanov_private_sg"
//  })
//
//  ingress {
//    security_group_id = var.public_sg
//  }
//}

#----------------------------------------------------------------------------- PostgreSQL RDS
resource "aws_db_instance" "this" {
  identifier           = "aboyanov"
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "12.3"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = data.aws_ssm_parameter.user.value
  password             = data.aws_ssm_parameter.pass.value
  db_subnet_group_name = aws_db_subnet_group.private.name
  skip_final_snapshot = true
  tags = var.tags
  depends_on = [data.aws_ssm_parameter.user, data.aws_ssm_parameter.pass]
}

