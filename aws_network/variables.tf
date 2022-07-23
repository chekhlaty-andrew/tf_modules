variable "name" {
  default = "petya"
}

variable "region" {
  description = "Please Enter AWS region to deploy Server"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Please Enter Environment DEV/PROD/UAT/QA"
  type        = string
  default     = "DEV"
}

variable "project" {
  description = "Please Enter Project name"
  type        = string
  default     = "EbuGusey"
}

variable "instance_type_map" {
  default = {
    "production"  = "m5.large"
    "development" = "t3.small"
    "uat"         = "t3.micro"
  }
}

variable "allow_port_map" {
  default = {
    "production"  = ["80", "443"]
    "development" = ["80", "443", "8080", "22"]
    "uat"         = ["80", "443", "22"]
  }
}

variable "instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "t3.small"
}

variable "allow_ports" {
  description = "List of Ports to open for server"
  type        = list(any)
  default     = ["80", "443", "1122", "8080"]
}

variable "sg_ingress_rules" {
  description = "Ingress security group rules"
  type        = map(any)
}



variable "egress_cidr_blocks4" {
  description = "List of IPv4 CIDR ranges to use on all egress rules"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}




variable "enable_detailed_monitoring" {
  type    = bool
  default = "false"
}

variable "common_tags" {
  description = "Common Tags to apply to all resources"
  type        = map(any)
  default = {
    Owner       = "A.Chekhlatyy"
    Project     = "Ebu Gusey"
    CostCenter  = "12345"
    Environment = "development"
  }
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}
variable "private_subnet_cidrs" {
  default = [
    "10.0.11.0/24",
    "10.0.22.0/24"
  ]

}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
