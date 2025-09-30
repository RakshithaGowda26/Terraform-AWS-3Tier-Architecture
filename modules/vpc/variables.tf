variable "cidr_block" {
  type = string
  description = "VPC IPV4 CIDR Range"
}

variable "webtier_sub1_az1" {
  type = string
  description = "Webtier subnet in AZ1"
}

variable "webtier_sub2_az2" {
  type = string
  description = "Webtier subnet in AZ2"
}

variable "apptier_sub1_az1" {
  type = string
  description = "apptier subnet in AZ1"
}

variable "apptier_sub2_az2" {
  type = string
  description = "apptier subnet in AZ2"
}

variable "dbtier_sub1_az1" {
  type = string
  description = "dbtier subnet in AZ1"
}

variable "dbtier_sub2_az2" {
  type = string
  description = "dbtier subnet in AZ2"
}

variable "route_cidr_block" {
  type        = string
  description = "route "
}