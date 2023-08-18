provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source = "./modules/vpc"
}

# module "ec2" {
#   source = "./modules/ec2"

#   vpc_id  = module.vpc.output_vpc.id
#   subnets = module.vpc.output_subnets

#   keys = {
#     "bastion-host" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUOQnr7vSMlxBcL7TsyowGlgi7W29jBY+piPDB9HDdB sonnv10121997.aws@gmail.com"
#     "private-app"  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEtq3r3r0g835hdFncmtWgXItLANBpdyIuClA+ysgna sonnv10121997.aws@gmail.com"
#   }

#   instances = {
#     bastion-host : {
#       ami                         = "ami-0df7a207adb9748c7"
#       instance_type               = "t2.micro"
#       associate_public_ip_address = true
#       subnet                      = "public-1a"
#       vpc_security_groups         = ["bastion-host"]
#       key_name                    = "key-bastion-host"
#     }
#     private-app : {
#       ami                 = "ami-0df7a207adb9748c7"
#       instance_type       = "t2.micro"
#       subnet              = "private-1a"
#       vpc_security_groups = ["private-app"]
#       key_name            = "key-private-app"
#     }
#   }

#   rds = {
#     private-rds : {
#       subnets             = ["private-1b", "private-1c"]
#       vpc_security_groups = ["private-rds"]
#       allocated_storage   = 10
#       engine              = "postgres"
#       engine_version      = "15.3"
#       identifier          = "private-rds"
#       username            = "postgres"
#       password            = "postgres"
#       instance_class      = "db.t3.micro"
#       availability_zone   = "ap-southeast-1b"
#       skip_final_snapshot = true
#     }
#   }
# }
