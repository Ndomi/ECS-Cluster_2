resource "aws_vpc" "ecs-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "ecs-vpc"
  }
}