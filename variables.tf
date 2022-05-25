variable "cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "vpc_block" {
  type    = string
  default = "10.1.0.0/16"
}

variable "public_block" {
  type    = string
  default = "10.1.1.0/24"
}

variable "private_block" {
  type    = string
  default = "10.1.2.0/24"
}

variable "avail_zone" {
  type    = string
  default = "us-east-1a"
}

variable "inst_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_owner" {
  type    = string
  default = "099720109477"
}

variable "service_ports" {
  type    = list(any)
  default = ["22", "80", "443"]
}