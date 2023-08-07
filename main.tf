terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc.cidr_block
  tags       = { Name = "vpc" }
}

### PUBLIC SUBNETS
resource "aws_subnet" "subnet_public_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets["public_1a"].cidr_block
  availability_zone = var.subnets["public_1a"].availability_zone
  tags              = { Name = "subnet-public-1a" }
}

resource "aws_subnet" "subnet_public_1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets["public_1b"].cidr_block
  availability_zone = var.subnets["public_1b"].availability_zone
  tags              = { Name = "subnet-public-1b" }
}

resource "aws_subnet" "subnet_public_1c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets["public_1c"].cidr_block
  availability_zone = var.subnets["public_1c"].availability_zone
  tags              = { Name = "subnet-public-1c" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "igw" }
}

resource "aws_default_route_table" "rtb_public" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags                   = { Name = "rtb-public" }

  route {
    cidr_block = var.rtbs["public"].cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rtb_public_association_1a" {
  subnet_id      = aws_subnet.subnet_public_1a.id
  route_table_id = aws_default_route_table.rtb_public.id
}

resource "aws_route_table_association" "rtb_public_association_1b" {
  subnet_id      = aws_subnet.subnet_public_1b.id
  route_table_id = aws_default_route_table.rtb_public.id
}

resource "aws_route_table_association" "rtb_public_association_1c" {
  subnet_id      = aws_subnet.subnet_public_1c.id
  route_table_id = aws_default_route_table.rtb_public.id
}

### PRIVATE SUBNETS
resource "aws_subnet" "subnet_private_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets["private_1a"].cidr_block
  availability_zone = var.subnets["private_1a"].availability_zone
  tags              = { Name = "subnet-private-1a" }
}

resource "aws_subnet" "subnet_private_1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets["private_1b"].cidr_block
  availability_zone = var.subnets["private_1b"].availability_zone
  tags              = { Name = "subnet-private-1b" }
}

resource "aws_subnet" "subnet_private_1c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets["private_1c"].cidr_block
  availability_zone = var.subnets["private_1c"].availability_zone
  tags              = { Name = "subnet-private-1c" }
}

resource "aws_eip" "eip" {

}

resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.subnet_public_1a.id
  allocation_id = aws_eip.eip.id
  depends_on    = [aws_internet_gateway.igw]
  tags          = { Name = "nat" }
}

resource "aws_route_table" "rtb_private" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "rtb-private" }

  route {
    cidr_block     = var.rtbs["private"].cidr_block
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "rtb_private_association_1a" {
  subnet_id      = aws_subnet.subnet_private_1a.id
  route_table_id = aws_route_table.rtb_private.id
}

resource "aws_route_table_association" "rtb_private_association_1b" {
  subnet_id      = aws_subnet.subnet_private_1b.id
  route_table_id = aws_route_table.rtb_private.id
}

resource "aws_route_table_association" "rtb_private_association_1c" {
  subnet_id      = aws_subnet.subnet_private_1c.id
  route_table_id = aws_route_table.rtb_private.id
}

### BASTION HOST
resource "aws_security_group" "sg_bastion_host" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "sg-bastion-host" }

  ingress {
    from_port   = var.sgrs["bastion_host_ingress"].from_port
    to_port     = var.sgrs["bastion_host_ingress"].to_port
    protocol    = var.sgrs["bastion_host_ingress"].protocol
    cidr_blocks = var.sgrs["bastion_host_ingress"].cidr_blocks
  }

  egress {
    from_port   = var.sgrs["bastion_host_egress"].from_port
    to_port     = var.sgrs["bastion_host_egress"].to_port
    protocol    = var.sgrs["bastion_host_egress"].protocol
    cidr_blocks = var.sgrs["bastion_host_egress"].cidr_blocks
  }
}

resource "aws_key_pair" "key_bastion_host" {
  key_name   = "key-bastion-host"
  public_key = var.keys["bastion_host"]
}

resource "aws_instance" "bastion_host" {
  ami                         = var.instances["bastion_host"].ami
  instance_type               = var.instances["bastion_host"].instance_type
  associate_public_ip_address = var.instances["bastion_host"].associate_public_ip_address
  subnet_id                   = aws_subnet.subnet_public_1a.id
  vpc_security_group_ids      = [aws_security_group.sg_bastion_host.id]
  key_name                    = aws_key_pair.key_bastion_host.key_name
  tags                        = { Name = "bastion-host" }
}

### PRIVATE APP
resource "aws_security_group" "sg_private_app" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "sg-private-app" }

  ingress {
    from_port       = var.sgrs["private_app_ingress"].from_port
    to_port         = var.sgrs["private_app_ingress"].to_port
    protocol        = var.sgrs["private_app_ingress"].protocol
    security_groups = [aws_security_group.sg_bastion_host.id]
  }

  egress {
    from_port   = var.sgrs["private_app_egress"].from_port
    to_port     = var.sgrs["private_app_egress"].to_port
    protocol    = var.sgrs["private_app_egress"].protocol
    cidr_blocks = var.sgrs["private_app_egress"].cidr_blocks
  }
}

resource "aws_key_pair" "key_private_app" {
  key_name   = "key-private-app"
  public_key = var.keys["private_app"]
}

resource "aws_instance" "private_app" {
  ami                    = var.instances["bastion_host"].ami
  instance_type          = var.instances["bastion_host"].instance_type
  subnet_id              = aws_subnet.subnet_private_1a.id
  vpc_security_group_ids = [aws_security_group.sg_private_app.id]
  key_name               = aws_key_pair.key_private_app.key_name
  tags                   = { Name = "private-app" }
}

### PRIVATE RDS
resource "aws_db_subnet_group" "subnet_group_private_rds" {
  name       = "subnet-group-private-rds"
  subnet_ids = [aws_subnet.subnet_private_1b.id, aws_subnet.subnet_private_1c.id]
  tags       = { Name = "subnet-group-private-rds" }
}

resource "aws_security_group" "sg_private_rds" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "sg-private-rds" }

  ingress {
    from_port       = var.sgrs["private_rds_ingress"].from_port
    to_port         = var.sgrs["private_rds_ingress"].to_port
    protocol        = var.sgrs["private_rds_ingress"].protocol
    security_groups = [aws_security_group.sg_private_app.id]
  }

  egress {
    from_port   = var.sgrs["private_rds_egress"].from_port
    to_port     = var.sgrs["private_rds_egress"].to_port
    protocol    = var.sgrs["private_rds_egress"].protocol
    cidr_blocks = var.sgrs["private_rds_egress"].cidr_blocks
  }
}

resource "aws_db_instance" "private_rds" {
  allocated_storage      = var.db_instances["private_rds"].allocated_storage
  engine                 = var.db_instances["private_rds"].engine
  engine_version         = var.db_instances["private_rds"].engine_version
  identifier             = var.db_instances["private_rds"].identifier
  username               = var.db_instances["private_rds"].username
  password               = var.db_instances["private_rds"].password
  instance_class         = var.db_instances["private_rds"].instance_class
  db_subnet_group_name   = aws_db_subnet_group.subnet_group_private_rds.name
  vpc_security_group_ids = [aws_security_group.sg_private_rds.id]
  availability_zone      = var.db_instances["private_rds"].availability_zone
  skip_final_snapshot    = var.db_instances["private_rds"].skip_final_snapshot
}
