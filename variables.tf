variable "cidr_block" {
  type        = string
  description = "VPC IPV4 CIDR Range"
}

variable "webtier_sub1_az1" {
  type        = string
  description = "Webtier subnet in AZ1"
}

variable "webtier_sub2_az2" {
  type        = string
  description = "Webtier subnet in AZ2"
}

variable "apptier_sub1_az1" {
  type        = string
  description = "apptier subnet in AZ1"
}

variable "apptier_sub2_az2" {
  type        = string
  description = "apptier subnet in AZ2"
}

variable "dbtier_sub1_az1" {
  type        = string
  description = "dbtier subnet in AZ1"
}

variable "dbtier_sub2_az2" {
  type        = string
  description = "dbtier subnet in AZ2"
}

variable "route_cidr_block" {
  type        = string
  description = "route "
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
  type      = string
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