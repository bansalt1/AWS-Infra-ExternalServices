aws_region         = "ap-south-1"
vpc_cidr           = "10.50.0.0/16"
public_subnet_cidr = "10.50.1.0/24"

instance_type = "t3.xlarge"
disk_size_gb  = 50

hosted_zone_name = "tf-support.hashicorpdemo.com"
record_name      = "ks-docker-es-ci"

tags = {
  project     = "aws-tf"
  environment = "dev"
  owner       = "kunal"
}

# DB vars
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20
db_username          = "postgres"
db_password          = "Iamdb123"
db_name              = "kunals"

# EC2 config
ec2_name       = "ubuntu-kunal"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."  # put your real public key
