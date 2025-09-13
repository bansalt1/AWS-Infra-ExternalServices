variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.50.1.0/24"
}

variable "instance_type" {
  type    = string
  default = "t3.xlarge"
}

variable "disk_size_gb" {
  type    = number
  default = 50
}

variable "hosted_zone_name" {
  type    = string
  default = "tf-support.hashicorpdemo.com"
}

variable "record_name" {
  type    = string
  default = "ksrepmd"
}

variable "tags" {
  type = map(string)
  default = {
    project     = "aws-tf"
    environment = "dev"
    owner       = "kunal"
  }
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  type    = string
  default = "Iamdb123"
}

variable "db_name" {
  type    = string
  default = "kunals"
}

variable "ssh_public_key" {
  type      = string
  sensitive = false
  default   = ""
}

variable "ec2_name" {
  type    = string
  default = "tf-web-ec2"
}
