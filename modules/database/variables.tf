variable "vpc_id" {
  type        = string
  description = "VPC ID where DB should be launched"
}

variable "db_subnet_ids" {
  type = list(string)
  description = "List of private subnet IDs for DB subnet group"
}

variable "db_security_group_id" {
  description = "Security group IDs that allow DB access"
}

variable "cluster_identifier" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "master_username" {
  type = string
}

variable "master_password" {
  type = string
  sensitive = true
}

variable "database_name" {
  type = string
}

variable "network_type" {
  type = string
}

variable "storage_encrypted" {
  type = bool
}

variable "backup_retention_period" {
  type = number
}

variable "deletion_protection" {
  type = bool
}