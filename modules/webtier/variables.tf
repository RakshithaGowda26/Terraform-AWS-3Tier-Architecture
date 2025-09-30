variable "webtier_security_group" {
  description = "Security group IDs that allow webtier access"
}

variable "webtier_subnet_ids" {
   type = map(string)
}

variable "iam_instance_profile" {
  description = "Name of the IAM instance profile for EC2 to access S3 and SSM"
}

variable "vpc_id" {
  description ="The ID of the created VPC"
}

variable "external_lb_sg" {
  description = "External ALB (only accessible outside the VPC)"
}

variable "az1_subnet" {
  description = "webtier subnet az1"
}

variable "az2_subnet" {
  description = "webtier subnet az2"
}

variable "internal_lb" {
  description = "internal_lb"
}

variable "s3_bucket" {
  description = "s3 bucket name"
}