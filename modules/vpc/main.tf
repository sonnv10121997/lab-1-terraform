terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc.cidr_block
  tags       = { Name = "vpc" }
}

resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags              = { Name = "subnet-${each.key}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "igw" }
}

resource "aws_eip" "eips" {
  for_each = { for rtb_key, rtb_value in var.rtbs : rtb_key => rtb_value if strcontains(rtb_key, "private") }
}

resource "aws_nat_gateway" "nats" {
  for_each = aws_eip.eips

  subnet_id     = aws_subnet.subnets["public-1a"].id
  allocation_id = each.value.id
  depends_on    = [aws_internet_gateway.igw]
  tags          = { Name = "nat" }
}

resource "aws_route_table" "rtbs" {
  for_each = var.rtbs

  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "rtb-${each.key}" }

  route {
    cidr_block     = each.value.cidr_block
    gateway_id     = strcontains(each.key, "private") ? null : aws_internet_gateway.igw.id
    nat_gateway_id = strcontains(each.key, "private") ? aws_nat_gateway.nats["private"].id : null
  }
}

resource "aws_route_table_association" "rtb_associations" {
  for_each = aws_subnet.subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.rtbs[strcontains(each.key, "public") ? "public" : "private"].id
}
