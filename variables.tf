variable "lab-1-private-rds-username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "lab-1-private-rds-password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "lab-1-public-key-bastion-host" {
  description = "Public key for bastion host"
  type        = string
}

variable "lab-1-public-key-private-app" {
  description = "Public key for private app"
  type        = string
}
