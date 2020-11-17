#---networking/outputs.tf

output "public_subnets" {
  value = aws_subnet.aboyanov_public_subnet.*.id
}

output "private_subnets" {
  value = aws_subnet.aboyanov_private_subnet.*.id
}

output "public_sg" {
  value = aws_security_group.aboyanov_public_sg.id
}

output "vpc_id" {
  value = aws_vpc.aboyanov_vpc.id
}
