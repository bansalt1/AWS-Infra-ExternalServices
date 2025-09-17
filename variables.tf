variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.50.1.0/24", "10.50.2.0/24"]
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

variable "db_identifier" {
  description = "DB identifier"
  type        = string
  default     = "kunals-postgres-db"
}

variable "db_subnet_group_name" {
  description = "Subnet group name for DB"
  type        = string
  default     = "tf-db-subnet-group"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to use for CI artifacts"
  type        = string
}

variable "ec2_name" {
  type    = string
  default = "tf-web-ec2"
}

variable "iam_role_name" {
  description = "IAM role name to attach to instance"
  type        = string
  default     = "s3-fullaccess-kunal"
}

variable "iam_instance_profile_name" {
  description = "Instance profile name"
  type        = string
  default     = "s3-fullaccess-kunal-instance-profile"
}

variable "web_sg_name" {
  type    = string
  default = "tf-web-sg"
}

variable "db_sg_name" {
  type    = string
  default = "tf-db-sg"
}

variable "eip_name" {
  type    = string
  default = "tf-web-eip"
}

variable "rt_name" {
  type    = string
  default = "tf-public-rt"
}

variable "vpc_name" {
  type    = string
  default = "tf-vpc"
}

variable "igw_name" {
  type    = string
  default = "tf-igw"
}
