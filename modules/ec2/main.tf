terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

resource "aws_key_pair" "keys" {
  for_each = var.keys

  key_name   = "key-${each.key}"
  public_key = each.value
}

resource "aws_security_group" "sgs" {
  for_each = var.sgs

  vpc_id = var.vpc_id
  tags   = { Name = "sg-${each.key}" }
}

resource "aws_security_group_rule" "sgrs" {
  for_each = var.sgrs

  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = each.value.cidr_blocks
  security_group_id        = aws_security_group.sgs[each.value.security_group].id
  source_security_group_id = each.value.source_security_group != null ? aws_security_group.sgs[each.value.source_security_group].id : null
}

resource "aws_instance" "instances" {
  for_each = var.instances

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  associate_public_ip_address = each.value.associate_public_ip_address
  subnet_id                   = var.subnets[each.value.subnet].id
  vpc_security_group_ids      = [for sg in each.value.vpc_security_groups : aws_security_group.sgs[sg].id]
  key_name                    = each.value.key_name
  tags                        = { Name = each.key }
}

resource "aws_db_subnet_group" "subnet_groups" {
  for_each = var.rds

  name       = "subnet-group-${each.key}"
  subnet_ids = [for subnet in each.value.subnets : var.subnets[subnet].id]
  # subnet_ids = [aws_subnet.subnet_private_1b.id, aws_subnet.subnet_private_1c.id]
  tags = { Name = "subnet-group-${each.key}" }
}

resource "aws_db_instance" "rds" {
  for_each = var.rds

  allocated_storage      = each.value.allocated_storage
  engine                 = each.value.engine
  engine_version         = each.value.engine_version
  identifier             = each.value.identifier
  username               = each.value.username
  password               = each.value.password
  instance_class         = each.value.instance_class
  db_subnet_group_name   = aws_db_subnet_group.subnet_groups[each.key].name
  vpc_security_group_ids = [for sg in each.value.vpc_security_groups : aws_security_group.sgs[sg].id]
  # vpc_security_group_ids = [aws_security_group.sg_private_rds.id]
  availability_zone   = each.value.availability_zone
  skip_final_snapshot = each.value.skip_final_snapshot
}
