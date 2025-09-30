resource "aws_s3_bucket" "mybucketgowda" {
  bucket = "mybucketgowda"
  region = "us-east-1"
  tags = {
    Name = "mybucketgowda"
  }
}


# 1. IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2_s3_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 2. Attach AmazonS3FullAccess policy
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# 3. Attach AmazonSSMManagedInstanceCore policy
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 4. IAM Instance Profile (required to attach role to EC2)
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_s3_ssm_instance_profile"
  role = aws_iam_role.ec2_role.name
}
