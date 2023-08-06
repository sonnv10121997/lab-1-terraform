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
  region = "ap-southeast-1"
}

resource "aws_vpc" "lab-1-vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "lab-1-vpc" }
}

### PUBLIC SUBNETS
resource "aws_subnet" "lab-1-subnet-public-1a" {
  vpc_id            = aws_vpc.lab-1-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-southeast-1a"
  tags              = { Name = "lab-1-subnet-public-1a" }
}

resource "aws_subnet" "lab-1-subnet-public-1b" {
  vpc_id            = aws_vpc.lab-1-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-1b"
  tags              = { Name = "lab-1-subnet-public-1b" }
}

resource "aws_subnet" "lab-1-subnet-public-1c" {
  vpc_id            = aws_vpc.lab-1-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1c"
  tags              = { Name = "lab-1-subnet-public-1c" }
}

resource "aws_internet_gateway" "lab-1-igw" {
  vpc_id = aws_vpc.lab-1-vpc.id
  tags   = { Name = "lab-1-igw" }
}

resource "aws_route_table" "lab-1-rtb-public" {
  vpc_id = aws_vpc.lab-1-vpc.id
  tags   = { Name = "lab-1-rtb-public" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab-1-igw.id
  }
}

resource "aws_route_table_association" "lab-1-rtb-public-association-1a" {
  subnet_id      = aws_subnet.lab-1-subnet-public-1a.id
  route_table_id = aws_route_table.lab-1-rtb-public.id
}

resource "aws_route_table_association" "lab-1-rtb-public-association-1b" {
  subnet_id      = aws_subnet.lab-1-subnet-public-1b.id
  route_table_id = aws_route_table.lab-1-rtb-public.id
}

resource "aws_route_table_association" "lab-1-rtb-public-association-1c" {
  subnet_id      = aws_subnet.lab-1-subnet-public-1c.id
  route_table_id = aws_route_table.lab-1-rtb-public.id
}

### PRIVATE SUBNETS
resource "aws_subnet" "lab-1-subnet-private-1a" {
  vpc_id            = aws_vpc.lab-1-vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "ap-southeast-1a"
  tags              = { Name = "lab-1-subnet-private-1a" }
}

resource "aws_subnet" "lab-1-subnet-private-1b" {
  vpc_id            = aws_vpc.lab-1-vpc.id
  cidr_block        = "10.0.32.0/20"
  availability_zone = "ap-southeast-1b"
  tags              = { Name = "lab-1-subnet-private-1b" }
}

resource "aws_subnet" "lab-1-subnet-private-1c" {
  vpc_id            = aws_vpc.lab-1-vpc.id
  cidr_block        = "10.0.48.0/20"
  availability_zone = "ap-southeast-1c"
  tags              = { Name = "lab-1-subnet-private-1c" }
}

resource "aws_eip" "lab-1-eip" {

}

resource "aws_nat_gateway" "lab-1-ngw" {
  subnet_id     = aws_subnet.lab-1-subnet-public-1a.id
  allocation_id = aws_eip.lab-1-eip.id
  tags          = { Name = "lab-1-ngw" }
  depends_on    = [aws_internet_gateway.lab-1-igw]
}

resource "aws_route_table" "lab-1-rtb-private" {
  vpc_id = aws_vpc.lab-1-vpc.id
  tags   = { Name = "lab-1-rtb-private" }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lab-1-ngw.id
  }
}

resource "aws_route_table_association" "lab-1-rtb-private-association-1a" {
  subnet_id      = aws_subnet.lab-1-subnet-private-1a.id
  route_table_id = aws_route_table.lab-1-rtb-private.id
}

resource "aws_route_table_association" "lab-1-rtb-private-association-1b" {
  subnet_id      = aws_subnet.lab-1-subnet-private-1b.id
  route_table_id = aws_route_table.lab-1-rtb-private.id
}

resource "aws_route_table_association" "lab-1-rtb-private-association-1c" {
  subnet_id      = aws_subnet.lab-1-subnet-private-1c.id
  route_table_id = aws_route_table.lab-1-rtb-private.id
}

### BASTION HOST
resource "aws_security_group" "lab-1-sg-bastion-host" {
  vpc_id = aws_vpc.lab-1-vpc.id
  name   = "lab-1-sg-bastion-host"
  tags   = { Name = "lab-1-sg-bastion-host" }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "lab-1-key-bastion-host" {
  key_name   = "lab-1-key-bastion-host"
  public_key = var.lab-1-public-key-bastion-host
}

resource "aws_instance" "lab-1-bastion-host" {
  ami                         = "ami-0df7a207adb9748c7"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.lab-1-subnet-public-1a.id
  vpc_security_group_ids      = [aws_security_group.lab-1-sg-bastion-host.id]
  key_name                    = aws_key_pair.lab-1-key-bastion-host.key_name
  tags                        = { Name = "lab-1-bastion-host" }
}

### PRIVATE APP
resource "aws_security_group" "lab-1-sg-private-app" {
  vpc_id = aws_vpc.lab-1-vpc.id
  name   = "lab-1-sg-private-app"
  tags   = { Name = "lab-1-sg-private-app" }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.lab-1-sg-bastion-host.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "lab-1-key-private-app" {
  key_name   = "lab-1-key-private-app"
  public_key = var.lab-1-public-key-private-app
}

resource "aws_instance" "lab-1-private-app" {
  ami                    = "ami-0df7a207adb9748c7"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.lab-1-subnet-private-1a.id
  vpc_security_group_ids = [aws_security_group.lab-1-sg-private-app.id]
  key_name               = aws_key_pair.lab-1-key-private-app.key_name
  tags                   = { Name = "lab-1-private-app" }
}

### PRIVATE RDS
resource "aws_db_subnet_group" "lab-1-subnet-group-private-rds" {
  name       = "lab-1-subnet-group-private-rds"
  subnet_ids = [aws_subnet.lab-1-subnet-private-1b.id, aws_subnet.lab-1-subnet-private-1c.id]
  tags       = { Name = "lab-1-subnet-group-private-rds" }
}

resource "aws_security_group" "lab-1-sg-private-rds" {
  vpc_id = aws_vpc.lab-1-vpc.id
  name   = "lab-1-sg-private-rds"
  tags   = { Name = "lab-1-sg-private-rds" }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lab-1-sg-private-app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "lab-1-private-rds" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "15.3"
  identifier             = "lab-1-private-rds"
  username               = var.lab-1-private-rds-username
  password               = var.lab-1-private-rds-password
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.lab-1-subnet-group-private-rds.name
  vpc_security_group_ids = [aws_security_group.lab-1-sg-private-rds.id]
  availability_zone      = "ap-southeast-1b"
  skip_final_snapshot    = true
}
