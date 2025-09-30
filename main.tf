module "my_vpc" {
  source           = "./modules/vpc"
  cidr_block       = var.cidr_block
  webtier_sub1_az1 = var.webtier_sub1_az1
  webtier_sub2_az2 = var.webtier_sub2_az2
  apptier_sub1_az1 = var.apptier_sub1_az1
  apptier_sub2_az2 = var.apptier_sub2_az2
  dbtier_sub1_az1  = var.dbtier_sub1_az1
  dbtier_sub2_az2  = var.dbtier_sub2_az2
  route_cidr_block = var.route_cidr_block
}

module "my_db" {
  source                  = "./modules/database"
  vpc_id                  = module.my_vpc.vpc_id
  db_subnet_ids           = [module.my_vpc.db_subnet_az1_id, module.my_vpc.db_subnet_az2_id]
  db_security_group_id    = module.my_vpc.db_security_group
  cluster_identifier      = var.cluster_identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  master_username         = var.master_username
  master_password         = var.master_password
  network_type            = var.network_type
  database_name           = var.database_name
  storage_encrypted       = var.storage_encrypted
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
}

module "storage" {
  source = "./modules/s3"
}

module "apptier" {
  source                 = "./modules/apptier"
  apptier_security_group = module.my_vpc.apptier_security_group
  apptier_subnet_ids = {
    az1 = module.my_vpc.apptier_sub1_az1_id
    az2 = module.my_vpc.apptier_sub2_az2_id
  }
  iam_instance_profile = module.storage.iam_instance_profile
  vpc_id               = module.my_vpc.vpc_id
  internal_lb_sg       = module.my_vpc.internal_lb_sg
  az1_subnet           = module.my_vpc.apptier_sub1_az1_id
  az2_subnet           = module.my_vpc.apptier_sub2_az2_id
  rds_endpoint         = module.my_db.rds_endpoint
  db_user              = var.master_username
  db_password          = var.master_password
  s3_bucket            = module.storage.s3_bucket
}

module "webtier" {
  source                 = "./modules/webtier"
  iam_instance_profile   = module.storage.iam_instance_profile
  webtier_security_group = module.my_vpc.webtier_security_group
  webtier_subnet_ids = {
    az1 = module.my_vpc.webtier_sub1_az1_id
    az2 = module.my_vpc.webtier_sub2_az2_id
  }
  vpc_id         = module.my_vpc.vpc_id
  external_lb_sg = module.my_vpc.external_lb_sg
  az1_subnet     = module.my_vpc.webtier_sub1_az1_id
  az2_subnet     = module.my_vpc.webtier_sub2_az2_id
  internal_lb    = module.apptier.internal_lb
  s3_bucket      = module.storage.s3_bucket
}