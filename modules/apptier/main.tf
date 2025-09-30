# Render DbConfig.js from template
resource "local_file" "dbconfig" {
  content = templatefile("${path.module}/DbConfig.js.tmpl", {
    db_host     = var.rds_endpoint
    db_user     = var.db_user
    db_password = var.db_password
  })

  filename = "${path.root}/application-code/app-tier/DbConfig.js"
}

# Upload all app-tier files EXCEPT DbConfig.js
resource "aws_s3_object" "app_code" {
  for_each = {
    for f in fileset("${path.root}/application-code/app-tier", "**/*") :
    f => f if f != "DbConfig.js"
  }

  bucket      = var.s3_bucket
  key         = "app-tier/${each.key}"
  source      = "${path.root}/application-code/app-tier/${each.key}"
  source_hash = filemd5("${path.root}/application-code/app-tier/${each.key}")
}

# Upload generated DbConfig.js separately
resource "aws_s3_object" "dbconfig_file" {
  bucket      = var.s3_bucket
  key         = "app-tier/DbConfig.js"
  source      = local_file.dbconfig.filename
  source_hash = filemd5(local_file.dbconfig.filename)

  depends_on = [local_file.dbconfig]
}

# Target Group for App Tier EC2 instances
resource "aws_lb_target_group" "apptier_tg" {
  name     = "apptier-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "apptier-tg"
  }
}

# Internal Application Load Balancer for App Tier
resource "aws_lb" "internal_lb" {
  name               = "apptier-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.internal_lb_sg]
  subnets            = [var.az1_subnet, var.az2_subnet]

  tags = {
    Name = "apptier-alb"
  }
}

# Listener for Internal Load Balancer
resource "aws_lb_listener" "internal_lb_listener" {
  load_balancer_arn = aws_lb.internal_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apptier_tg.arn
  }
}

# Launch Template for App Tier Instances
resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-launch-template-"
  description   = "Launch template for app tier EC2 instances"

  image_id      = "ami-00ca32bbc84273381"  # Use a base AMI initially, updated with AMI from instance later
  instance_type = "t2.micro"

  iam_instance_profile {
    name = var.iam_instance_profile
  }

 # user_data = base64encode(templatefile("${path.module}/userdata.sh", {
 #   rds_endpoint  = var.rds_endpoint
  #  db_user       = var.db_user
  #  db_password   = var.db_password
  #  s3_bucket     = var.s3_bucket
 # }))

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.apptier_security_group]
    subnet_id                   = var.az1_subnet  # Default subnet, ASG spreads across all
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "AppTier"
    }
  }
}

# Auto Scaling Group for App Tier
resource "aws_autoscaling_group" "app_asg" {
  name                = "app-asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = [var.az1_subnet, var.az2_subnet]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.apptier_tg.arn]

  tag {
    key                 = "Name"
    value               = "AppTier"
    propagate_at_launch = true
  }
}