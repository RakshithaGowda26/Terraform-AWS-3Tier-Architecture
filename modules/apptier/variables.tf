variable "apptier_security_group" {
  description = "Security group IDs that allow apptier access"
}

variable "apptier_subnet_ids" {
   type = map(string)
  description = "List of private subnet IDs for DB subnet group"
}

variable "iam_instance_profile" {
  description = "Name of the IAM instance profile for EC2 to access S3 and SSM"
}

variable "vpc_id" {
  description ="The ID of the created VPC"
}

variable "internal_lb_sg" {
  description = "internal ALB (only accessible within the VPC)"
}

variable "az1_subnet" {
  description = "apptier subnet az1"
}

variable "az2_subnet" {
  description = "apptier subnet az2"
}

variable "rds_endpoint" {
  description = "database end point for DB configuration"
}

variable "db_user" {
  description = "db_user information"
}

variable "db_password" {
  sensitive = true
}

variable "s3_bucket" {
  description = "bucket name for configurations"
}