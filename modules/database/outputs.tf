output "rds_endpoint" {
  value = aws_rds_cluster_instance.aurora_writer.endpoint
}