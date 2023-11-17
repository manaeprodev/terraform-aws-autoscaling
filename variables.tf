variable "aws_region" {
  type        = string
  description = "AWS Region"
  default = "us-east-1"
}

variable "vpc_name" {
  type = string
  description = "Name of the VPC"
  default = "insset-ccm"
}
