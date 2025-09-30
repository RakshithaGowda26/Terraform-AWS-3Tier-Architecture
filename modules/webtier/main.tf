# Render nginx.conf with internal LB DNS
resource "local_file" "nginx" {
  content  = templatefile("${path.module}/nginx.conf.tpl", {
    internal_lb_dns = var.internal_lb
  })
  filename = "${path.root}/application-code/nginx.conf"
}

# Upload web-tier React project files to S3
resource "aws_s3_object" "web_tier_code" {
  for_each = fileset("${path.root}/application-code/web-tier", "**/*")

  bucket      = var.s3_bucket
  key         = "web-tier/${each.value}"
  source      = "${path.root}/application-code/web-tier/${each.value}"
  source_hash = filemd5("${path.root}/application-code/web-tier/${each.value}")
}

# Upload rendered nginx.conf to S3
resource "aws_s3_object" "nginx" {
  bucket      = var.s3_bucket
  key         = "nginx.conf"
  source      = local_file.nginx.filename
  source_hash = filemd5(local_file.nginx.filename)

  depends_on = [local_file.nginx]
}

# Target Group for Web Tier EC2 instances
resource "aws_lb_target_group" "webtier_tg" {
  name     = "webtier-tg"
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
    Name = "webtier-tg"
  }
}

# External Application Load Balancer for Web Tier
resource "aws_lb" "external_lb" {
  name               = "webtier-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.external_lb_sg]
  subnets            = [var.az1_subnet, var.az2_subnet]

  tags = {
    Name = "webtier-alb"
  }
}

# Listener for External Load Balancer
resource "aws_lb_listener" "external_lb_listener" {
  load_balancer_arn = aws_lb.external_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webtier_tg.arn
  }
}

# Launch Template for Web Tier Instances
resource "aws_launch_template" "web_lt" {
  name_prefix   = "web-launch-template-"
  description   = "Launch template for web tier EC2 instances"

  image_id      = "ami-00ca32bbc84273381"  # Initial AMI, updated with AMI from instance later
  instance_type = "t2.micro"

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  #user_data = base64encode(templatefile("${path.module}/userdata.sh", {
   # s3_bucket = var.s3_bucket
 # }))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.webtier_security_group]
    subnet_id                   = var.az1_subnet  # Default subnet, ASG spreads across all
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WebTier"
    }
  }
}

# Auto Scaling Group for Web Tier
resource "aws_autoscaling_group" "web_asg" {
  name                = "web-asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = [var.az1_subnet, var.az2_subnet]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.webtier_tg.arn]

  tag {
    key                 = "Name"
    value               = "WebTier"
    propagate_at_launch = true
  }
}