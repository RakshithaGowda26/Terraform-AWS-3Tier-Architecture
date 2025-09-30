resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "webtier_sub1_az1" {
  vpc_id = aws_vpc.myvpc.id
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  cidr_block = var.webtier_sub1_az1
  tags = {
    Name = "webtier_sub1_az1"
  }
}

resource "aws_subnet" "webtier_sub2_az2" {
  vpc_id = aws_vpc.myvpc.id
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  cidr_block = var.webtier_sub2_az2
  tags = {
    Name = "webtier_sub2_az2"
  }
}

resource "aws_subnet" "appier_sub1_az1" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1a"
  cidr_block = var.apptier_sub1_az1
  tags = {
    Name = "apptier_sub1_az1"
  }
}

resource "aws_subnet" "apptier_sub2_az2" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1b"
  cidr_block = var.apptier_sub2_az2
  tags = {
    Name = "apptier_sub2_az2"
  }
}

resource "aws_subnet" "dbtier_sub1_az1" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1a"
  cidr_block = var.dbtier_sub1_az1
  tags = {
    Name = "dbtier_sub1_az1"
  }
}

resource "aws_subnet" "dbtier_sub2_az2" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1b"
  cidr_block = var.dbtier_sub2_az2
  tags = {
    Name = "dbtier_sub2_az2"
  }
}

resource "aws_internet_gateway" "tier_igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name="tier_igw"
  }
}

resource "aws_eip" "nat_epi_az1" {
  domain = "vpc"
}

resource "aws_eip" "nat_epi_az2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "tier_ngw_az1" {
  subnet_id = aws_subnet.webtier_sub1_az1.id
  allocation_id = aws_eip.nat_epi_az1.id
  tags = {
    Name = "tier_ngw_az1"
  }
}

resource "aws_nat_gateway" "tier_ngw_az2" {
  subnet_id = aws_subnet.webtier_sub2_az2.id
  allocation_id = aws_eip.nat_epi_az2.id
  tags = {
    Name = "tier_ngw_az2"
  }
}

resource "aws_route_table" "rt_table_pub" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "rt_table_pub"
  }

  route {
    cidr_block = var.route_cidr_block
    gateway_id = aws_internet_gateway.tier_igw.id
  }
}

resource "aws_route_table_association" "rt_association_public" {
  for_each = {
    az1 = aws_subnet.webtier_sub1_az1.id
    az2 = aws_subnet.webtier_sub2_az2.id
  }
  route_table_id = aws_route_table.rt_table_pub.id
  subnet_id = each.value
}

resource "aws_route_table" "rt_table_nat_az1" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "rt_table_nat_az1"
  }

  route {
    cidr_block = var.route_cidr_block
    gateway_id = aws_nat_gateway.tier_ngw_az1.id
  }
}

resource "aws_route_table_association" "rt_association_nat_az1" {
  route_table_id = aws_route_table.rt_table_nat_az1.id
  subnet_id = aws_subnet.appier_sub1_az1.id
}

resource "aws_route_table" "rt_table_nat_az2" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "rt_table_nat_az2"
  }

  route {
    cidr_block = var.route_cidr_block
    gateway_id = aws_nat_gateway.tier_ngw_az2.id
  }
}

resource "aws_route_table_association" "rt_association_nat_az2" {
  route_table_id = aws_route_table.rt_table_nat_az2.id
  subnet_id = aws_subnet.apptier_sub2_az2.id
}

resource "aws_security_group" "internetfacing_lb_sg" {
  description = "Security group for internet facing load balancer"
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name="internetfacing_lb_sg"
  }

  ingress  {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow http from anywhere"
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webtier_sg" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name="webtier_sg"
  }

  ingress  {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    description = "Allow traffic from internetfacing lb to web tier"
    security_groups = [aws_security_group.internetfacing_lb_sg.id]
  }

   egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internal_lb_sg" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name="internal_lb_sg"
  }

  ingress  {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    description = "Allow traffic from web tier to internal lb"
    security_groups = [aws_security_group.webtier_sg.id]
  }

   egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "apptier_sg" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name="apptier_sg"
  }

  ingress  {
    from_port = 4000
    to_port = 4000
    protocol = "tcp"
    description = "Allow traffic from internal lb to app tier"
    security_groups = [aws_security_group.internal_lb_sg.id]
  }

   egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dbtier_sg" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name="dbtier_sg"
  }

  ingress  {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    description = "Allow traffic from apptier to db tier"
    security_groups = [aws_security_group.apptier_sg.id]
  }

   egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}