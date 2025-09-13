locals {
  zone_name = endswith(var.hosted_zone_name, ".") ? var.hosted_zone_name : "${var.hosted_zone_name}."
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.tags, { Name = "tf-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "tf-igw" })
}

# Subnet A
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags                    = merge(var.tags, { Name = "tf-public-subnet-a" })
}

# Subnet B (new, in different AZ)
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.50.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags                    = merge(var.tags, { Name = "tf-public-subnet-b" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, { Name = "tf-public-rt" })
}

resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web_sg" {
  name        = "tf-web-sg"
  description = "Allow SSH/HTTP/HTTPS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "tf-web-sg" })
}

# DB security group
resource "aws_security_group" "db_sg" {
  name        = "tf-db-sg"
  description = "Allow Postgres from web instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres from web_sg"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "tf-db-sg" })
}

# IAM role already exists
data "aws_iam_role" "existing_s3_role" {
  name = "s3-fullaccess-kunal"
}

resource "aws_iam_instance_profile" "web_profile" {
  name = "s3-fullaccess-kunal-instance-profile"
  role = data.aws_iam_role.existing_s3_role.name
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.web_profile.name

  root_block_device {
    volume_size = var.disk_size_gb
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ubuntu/.ssh
              echo "${file("${path.root}/jenkins_gcp_key.pub")}" > /home/ubuntu/.ssh/authorized_keys
              chown -R ubuntu:ubuntu /home/ubuntu/.ssh
              chmod 700 /home/ubuntu/.ssh
              chmod 600 /home/ubuntu/.ssh/authorized_keys
              EOF

  tags = merge(var.tags, { Name = var.ec2_name })
}

resource "aws_eip" "web_eip" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "tf-web-eip" })
}

resource "aws_eip_association" "web_eip_assoc" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.web_eip.id
}

# RDS resources
resource "aws_db_subnet_group" "db_subnets" {
  name       = "tf-db-subnet-group"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = merge(var.tags, { Name = "tf-db-subnet-group" })
}

resource "aws_db_instance" "postgres" {
  identifier              = "kunals-postgres-db"
  engine                  = "postgres"
  engine_version          = "15.8"                   
  allocated_storage       = var.db_allocated_storage
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  apply_immediately       = true

  tags = merge(var.tags, { Name = "tf-postgres-db" })
}

# S3 bucket (no ACL, private by default)
resource "aws_s3_bucket" "ci_bucket" {
  bucket        = "kunal-test-ci-fdo"
  force_destroy = true

  tags = merge(var.tags, { Name = "kunal-test-ci-fdo" })
}

data "aws_route53_zone" "target" {
  name         = local.zone_name
  private_zone = false
}

resource "aws_route53_record" "a_record" {
  zone_id = data.aws_route53_zone.target.zone_id
  name    = "${var.record_name}.${chomp(data.aws_route53_zone.target.name)}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.web_eip.public_ip]
}
