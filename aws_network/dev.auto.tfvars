# file should be terraform.tfvars
# or *.auto.tfvars

sg_ingress_rules = {
  "1" = {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  },
  "2" = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["188.190.229.13/32"]
    description = "SSH"
  },
  "3" = {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }
}

environment                = "development"
project                    = "EbuGusey"
enable_detailed_monitoring = false
instance_type              = "t3.micro"
region                     = "eu-west-2"
vpc_cidr                   = "172.31.64.0/20"


common_tags = {
  Owner       = "A.Chekhlatyy"
  Project     = "development-EbuGusey"
  CostCenter  = "12345"
  Environment = "development"
}



public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.11.0/24", "10.1.22.0/24"]
