variable "vpc_id" {
  type = string
}

variable "keys" {
  description = "Public keys map"
  type        = map(string)
}

variable "sgs" {
  type = map(object({
    description = optional(string)
    name        = optional(string)
    tags        = optional(object({}))
  }))

  default = {
    bastion-host : {}
    private-app : {}
    private-rds : {}
  }
}

variable "sgrs" {
  type = map(object({
    type                  = string
    from_port             = number
    to_port               = number
    protocol              = string
    security_group        = string
    cidr_blocks           = optional(list(string))
    source_security_group = optional(string)
  }))

  default = {
    bastion-host-ingress : {
      type           = "ingress"
      from_port      = 22
      to_port        = 22
      protocol       = "tcp"
      cidr_blocks    = ["0.0.0.0/0"]
      security_group = "bastion-host"
    }
    bastion-host-egress : {
      type           = "egress"
      from_port      = 0
      to_port        = 0
      protocol       = "-1"
      cidr_blocks    = ["0.0.0.0/0"]
      security_group = "bastion-host"
    }
    private-app-ingress : {
      type                  = "ingress"
      from_port             = 22
      to_port               = 22
      protocol              = "tcp"
      source_security_group = "bastion-host"
      security_group        = "private-app"
    }
    private-app-egress : {
      type           = "egress"
      from_port      = 0
      to_port        = 0
      protocol       = "-1"
      cidr_blocks    = ["0.0.0.0/0"]
      security_group = "private-app"
    }
    private-rds-ingress : {
      type                  = "ingress"
      from_port             = 5432
      to_port               = 5432
      protocol              = "tcp"
      source_security_group = "private-app"
      security_group        = "private-rds"
    }
    private-rds-egress : {
      type           = "egress"
      from_port      = 0
      to_port        = 0
      protocol       = "-1"
      cidr_blocks    = ["0.0.0.0/0"]
      security_group = "private-rds"
    }
  }
}

variable "instances" {
  type = map(object({
    ami                         = string
    instance_type               = string
    associate_public_ip_address = optional(bool)
    subnet                      = optional(string)
    vpc_security_groups         = optional(list(string))
    key_name                    = optional(string)
  }))
}

variable "rds" {
  description = "DB instances configuration"
  type = map(object({
    subnets             = list(string)
    vpc_security_groups = optional(list(string))
    allocated_storage   = number
    engine              = string
    engine_version      = string
    identifier          = string
    username            = string
    password            = string
    instance_class      = string
    availability_zone   = string
    skip_final_snapshot = bool
  }))
}

variable "subnets" {
  type = map(object({
    id = string
  }))
}
