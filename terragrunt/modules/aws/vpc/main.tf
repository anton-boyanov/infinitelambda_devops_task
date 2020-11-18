terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
  required_version = "0.12.16"
}

data "aws_availability_zones" "available" {}

#---VPC---

resource "aws_vpc" "aboyanov_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "aboyanov_vpc"
  })
}

#---Internet Gateway---

resource "aws_internet_gateway" "aboyanov_igw" {
  vpc_id = aws_vpc.aboyanov_vpc.id

  tags = merge(var.tags, {
    Name = "aboyanov_igw"
  })
}

#---Rout Tables---

resource "aws_route_table" "aboyanov_public_rt" {
  vpc_id = aws_vpc.aboyanov_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aboyanov_igw.id
  }

  tags = merge(var.tags, {
    Name = "aboyanov_public_rt"
  })
}

resource "aws_route_table" "aboyanov_private_rt" {
  vpc_id = aws_vpc.aboyanov_vpc.id
  tags = merge(var.tags, {
    Name = "aboyanov_private_rt"
  })
}

#---Subnets---

resource "aws_subnet" "aboyanov_public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.aboyanov_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name = "aboyanov_public${count.index + 1}"
    Class = "APP"
  })
}

resource "aws_subnet" "aboyanov_private_subnet" {
  count = 2
  vpc_id = aws_vpc.aboyanov_vpc.id
  cidr_block = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name = "aboyanov_private${count.index + 3}"
    Class = "DATA"
  })
}

#---Route Table ACCOSSIATIONS---

resource "aws_route_table_association" "aboyanov_public_assoc" {
  count          = length(aws_subnet.aboyanov_public_subnet)
  subnet_id      = aws_subnet.aboyanov_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.aboyanov_public_rt.id
}

resource "aws_route_table_association" "aboyanov_private_rt_assoc" {
  count          = length(aws_subnet.aboyanov_public_subnet)
  subnet_id      = aws_subnet.aboyanov_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.aboyanov_private_rt.id
}


#---PUBLIC SG

resource "aws_security_group" "aboyanov_public_sg" {
  name        = "aboyanov_public_sg"
  description = "Used for access to public instances"
  vpc_id      = aws_vpc.aboyanov_vpc.id

  tags = merge(var.tags, {
    Name = "aboyanov_public_sg"
  })

  #SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.accessip]
  }

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.accessip]
  }

  #Jenkins

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.accessip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.aboyanov_vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_access_from_ec2" {
  type      = "ingress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  security_group_id        = aws_default_security_group.default.id
  source_security_group_id = aws_security_group.aboyanov_public_sg.id
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = merge(var.tags, {
    Name = "aboyanov-task"
  })
}

resource "aws_vpc_dhcp_options_association" "a" {
  vpc_id          = aws_vpc.aboyanov_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}
