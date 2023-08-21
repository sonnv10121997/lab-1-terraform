variable "vpc" {
  type = object({
    cidr_block = string
  })

  default = {
    cidr_block = "10.0.0.0/16"
  }
}

variable "subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    public-1a : {
      cidr_block        = "10.0.0.0/24"
      availability_zone = "ap-southeast-1a"
    }
    public-1b : {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "ap-southeast-1b"
    }
    public-1c : {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "ap-southeast-1c"
    }
    private-1a : {
      cidr_block        = "10.0.16.0/20"
      availability_zone = "ap-southeast-1a"
    }
    private-1b : {
      cidr_block        = "10.0.32.0/20"
      availability_zone = "ap-southeast-1b"
    }
    private-1c : {
      cidr_block        = "10.0.48.0/20"
      availability_zone = "ap-southeast-1c"
    }
  }
}

variable "rtbs" {
  type = map(object({
    cidr_block = string
    private    = optional(bool, false)
  }))

  default = {
    public : {
      cidr_block = "0.0.0.0/0"
    }
    private : {
      cidr_block = "0.0.0.0/0"
      private    = true
    }
  }
}
