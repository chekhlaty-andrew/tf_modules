

###terraform {
###  backend "s3" {
###    bucket = "andrew-chekhlatyy-lessons-tfstate"
###    key     = "dev/network/terraform.tfstate"
###    region  = "us-east-1"
###    encrypt = "true"
###  }
###}



# local variables

locals {
  full_project_name = "${var.environment}-${var.project}"
}

locals {
  description_etc = var.environment == "uat" ? "ebuutey" : "ebugusey"
  count_ec2       = var.environment == "uat" ? 1 : 0
}


locals {
  az_list  = join(",", data.aws_availability_zones.availavle.names)
  region   = data.aws_region.current.description
  location = "In ${local.region} threre are AZ: ${local.az_list}"
}

locals {
  ec2_instance_type = lookup(var.instance_type_map, var.environment)
}

# null resource
resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "echo create VPC $(date) >>ebuutey.txt"
  }
}

resource "null_resource" "command3" {
  provisioner "local-exec" {
    command     = "print ('create VPC!')"
    interpreter = ["python", "-c"]
  }
}

# data
data "aws_availability_zones" "availavle" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_vpcs" "myvpcs" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}


data "aws_ami" "lastes_amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"] # Canonical
}

#variable "vpc_cidr" {
#  default = "172.31.64.0/20"
#}

resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags             = merge(var.common_tags, { Name = "main_vpc" })
  provisioner "local-exec" {
    command = "echo Ebu gusey"
  }
}



resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "!#$&"

  keepers = {
    kepeer1 = var.name
    //keperr2 = var.something
  }
}



// Store Password in SSM Parameter Store
resource "aws_ssm_parameter" "rds_password" {
  name        = "/prod/mysql"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
}



#------------------aws default subnet ---------------
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.availavle.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.availavle.names[1]
}

#------------------aws subnet ---------------

resource "aws_subnet" "public_subnets1" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.availavle.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
  }
}


#-----------------internet gateway--------------------

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(var.common_tags, { Name = "main_igw" })
}

#-----------------route table--------------------

resource "aws_route_table" "rt_public_subnets1" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    Name = "${var.environment}-route-public-subnets"
  }
  depends_on = [aws_vpc.main_vpc]
}

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets1[*].id)
  route_table_id = aws_route_table.rt_public_subnets1.id
  subnet_id      = element(aws_subnet.public_subnets1[*].id, count.index)
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets1[*].id
}
#--------------------ssl certificate-----------------
resource "aws_acm_certificate" "tch-cert" {
  private_key       = file("private.key")
  certificate_body  = file("actual_cert.cer")
  certificate_chain = file("inter.cer")
}
#--------NAT GAtaays with elastic IPs-----------------

resource "aws_eip" "nat" {
  count = length(var.private_subnet_cidrs)
  vpc   = true
  tags = {
    Name = "${var.environment}-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public_subnets1[*].id, count.index)
  tags = {
    Name = "${var.environment}-nat-gw-${count.index + 1}"
  }

}

#--------------Private Subnets and Routing-------------------------

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.availavle.names[count.index]
  tags = {
    Name = "${var.environment}-private-${count.index + 1}"
  }
}

resource "aws_route_table" "private_subnets" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.environment}-route-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_routes" {
  count          = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
}

#==============================================================
