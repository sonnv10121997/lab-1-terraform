variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc" {
  description = "VPC configuration"
  type = object({
    cidr_block = string
  })
}

variable "subnets" {
  description = "Subnets map configuration"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "rtbs" {
  description = "Route tables map configuration"
  type = map(object({
    cidr_block = string
  }))
}

variable "sgrs" {
  description = "Security group rules map configuration"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
  }))
}

variable "keys" {
  description = "Public keys map"
  type        = map(string)
}

variable "instances" {
  description = "EC2 instances configuration"
  type = map(object({
    ami                         = string
    instance_type               = string
    associate_public_ip_address = optional(bool)
  }))
}

variable "db_instances" {
  description = "DB instances configuration"
  type = map(object({
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
