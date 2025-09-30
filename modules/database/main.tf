resource "aws_db_subnet_group" "db_subnets_group" {
  name = "db_subnets_group"
  subnet_ids = var.db_subnet_ids
  tags = {
    Name = "db_subnets_group"
  }
}

resource "aws_rds_cluster" "aurora_rds_cluster" {
  cluster_identifier = var.cluster_identifier
  engine = var.engine # Aurora MySQL compatible
  engine_version =var.engine_version
  master_username = var.master_username
  master_password = var.master_password
  database_name = var.database_name
  network_type = var.network_type
  db_subnet_group_name = aws_db_subnet_group.db_subnets_group.name
  vpc_security_group_ids = [var.db_security_group_id]
  availability_zones = ["us-east-1a","us-east-1b"]
  storage_encrypted = var.storage_encrypted
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = "07:00-09:00"
  preferred_maintenance_window = "sun:05:00-sun:06:00"
  deletion_protection     = var.deletion_protection
  skip_final_snapshot = true

  # Dev/Test template → no high availability requirement,
  # If you want Multi-AZ Aurora, you can create at least 2 instances in different AZs (below)
}

# 3. Aurora Cluster Instances (Reader/Writer)
resource "aws_rds_cluster_instance" "aurora_writer" {
  identifier         = "aurora-writer-1"
  cluster_identifier = aws_rds_cluster.aurora_rds_cluster.id
  instance_class     = "db.r5.large" 
  engine             = aws_rds_cluster.aurora_rds_cluster.engine
  publicly_accessible = false
}

resource "aws_rds_cluster_instance" "aurora_reader" {
  identifier         = "aurora-reader-1"
  cluster_identifier = aws_rds_cluster.aurora_rds_cluster.id
  instance_class     = "db.r5.large"
  engine             = aws_rds_cluster.aurora_rds_cluster.engine
  publicly_accessible = false
}