output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.main_vpc.cidr_block
}

output "igw_id" {
  value = aws_internet_gateway.main_igw.id
}
