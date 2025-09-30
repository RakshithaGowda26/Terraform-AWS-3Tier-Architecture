output "iam_instance_profile" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}

output "s3_bucket" {
  value = aws_s3_bucket.mybucketgowda.bucket
}