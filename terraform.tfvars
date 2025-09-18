aws_region   = "ap-south-1"
environment  = ""

# Networking
vpc_cidr            = "10.60.0.0/16"
public_subnet_cidrs = ["10.60.1.0/24", "10.60.2.0/24"]

# EC2
instance_type = "t3.xlarge"
disk_size_gb  = 50

# Hosted zone
hosted_zone_name = "tf-support.hashicorpdemo.com"

# Tags
tags = {
  project     = "aws-tf1"
  environment = "dev1"
  owner       = "kunal1"
}

# DB
db_instance_class    = "db.t3.xlarge"
db_allocated_storage = 20
db_engine            = "postgres"
db_engine_version    = "15.8"
db_username          = "postgres"
db_password          = ""
db_name              = "kunals"

# S3
s3_bucket_prefix = "ks-test-docker-fdo"

# IAM
iam_role_name               = "s3-fullaccess-kunal"
iam_instance_profile_prefix = "s3-fullaccess-ks-instance-profile"
