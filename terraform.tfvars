region = "ap-southeast-1"

vpc = {
  cidr_block = "10.0.0.0/16"
}

subnets = {
  "public_1a" = {
    cidr_block        = "10.0.0.0/24"
    availability_zone = "ap-southeast-1a"
  },
  "public_1b" = {
    cidr_block        = "10.0.1.0/24"
    availability_zone = "ap-southeast-1b"
  },
  "public_1c" = {
    cidr_block        = "10.0.2.0/24"
    availability_zone = "ap-southeast-1c"
  },
  "private_1a" = {
    cidr_block        = "10.0.16.0/20"
    availability_zone = "ap-southeast-1a"
  },
  "private_1b" = {
    cidr_block        = "10.0.32.0/20"
    availability_zone = "ap-southeast-1b"
  },
  "private_1c" = {
    cidr_block        = "10.0.48.0/20"
    availability_zone = "ap-southeast-1c"
  },
}

rtbs = {
  "public" = {
    cidr_block = "0.0.0.0/0"
  },
  "private" = {
    cidr_block = "0.0.0.0/0"
  },
}

sgrs = {
  "bastion_host_ingress" = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  "bastion_host_egress" = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  },
  "private_app_ingress" = {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  },
  "private_app_egress" = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  },
  "private_rds_ingress" = {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
  },
  "private_rds_egress" = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  },
}

instances = {
  "bastion_host" = {
    ami                         = "ami-0df7a207adb9748c7"
    instance_type               = "t2.micro"
    associate_public_ip_address = true
  },
  "private_app" = {
    ami           = "ami-0df7a207adb9748c7"
    instance_type = "t2.micro"
  },
}

db_instances = {
  "private_rds" = {
    allocated_storage   = 10
    engine              = "postgres"
    engine_version      = "15.3"
    identifier          = "private-rds"
    instance_class      = "db.t3.micro"
    availability_zone   = "ap-southeast-1b"
    skip_final_snapshot = true
  },
}

keys = {
  "bastion_host" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUOQnr7vSMlxBcL7TsyowGlgi7W29jBY+piPDB9HDdB sonnv10121997.aws@gmail.com",
  "private_app"  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEtq3r3r0g835hdFncmtWgXItLANBpdyIuClA+ysgna sonnv10121997.aws@gmail.com",
}
