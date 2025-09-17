aws_region = "ap-south-1"

# Networking
vpc_cidr           = "10.50.0.0/16"
public_subnet_cidrs = ["10.50.1.0/24", "10.50.2.0/24"]

# EC2
instance_type = "t3.xlarge"
disk_size_gb  = 50
ec2_name      = "tfe-aws-docker-es"

# Hosted zone / DNS
hosted_zone_name = "tf-support.hashicorpdemo.com"
record_name      = "ks-docker-es-ci"

# Tags
tags = {
  project     = "aws-tf"
  environment = "dev"
  owner       = "kunal"
}

# DB
db_instance_class     = "db.t3.xlarge"
db_allocated_storage  = 20
db_username           = "postgres"
db_password           = "" # Password for database
db_name               = "kunals"
db_identifier         = "kunals-postgres-db"
db_subnet_group_name  = "tfe-db-subnet-group"

# S3
s3_bucket_name = "kunal-test-docker-fdo"

# IAM
iam_role_name              = "s3-fullaccess-kunal"
iam_instance_profile_name  = "s3-fullaccess-ks-instance-profile"

# Resource names
web_sg_name = "tf-web-sg"
db_sg_name  = "tf-db-sg"
eip_name    = "tf-web-eip"
rt_name     = "tf-public-rt"
vpc_name    = "tf-vpc"
igw_name    = "tf-igw"
