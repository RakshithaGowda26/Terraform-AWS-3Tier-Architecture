output "vpc_id" {
    value = aws_vpc.myvpc.id
    description = "The ID of the created VPC"
}

output "db_subnet_az1_id" {
  value = aws_subnet.dbtier_sub1_az1.id
}

output "db_subnet_az2_id" {
  value = aws_subnet.dbtier_sub2_az2.id
}

output "db_security_group" {
  value = aws_security_group.dbtier_sg.id
}

output "apptier_security_group" {
  value = aws_security_group.apptier_sg.id
}

output "webtier_sub2_az2_id" {
  value = aws_subnet.webtier_sub2_az2.id
}

output "webtier_sub1_az1_id" {
  value = aws_subnet.webtier_sub1_az1.id
}
output "apptier_sub2_az2_id" {
  value = aws_subnet.apptier_sub2_az2.id
}

output "apptier_sub1_az1_id" {
  value = aws_subnet.appier_sub1_az1.id
}

output "webtier_security_group" {
  value = aws_security_group.webtier_sg.id
}

output "internal_lb_sg" {
  value = aws_security_group.internal_lb_sg.id
}

output "external_lb_sg" {
  value = aws_security_group.internetfacing_lb_sg.id
}