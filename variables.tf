variable "aws_region" {
  type = string
  description = "AWS Region where you want to deploy your services"
}

variable "organization" {
  type = string
  description = "Organization name"
}

variable "country" {
  type = string
  description = "Country code (2 characters)"
}

variable "vpc_cidr" {
  type = string
  description = "VPC CIDR"
}

variable "web_cidr" {
  type = string
  description = "CIDR for Web Subnet"
}