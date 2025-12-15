// main.tf
terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket  = "akhil-terraform-tf-state-bucket"
    key     = "task_5/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ----------------------------
# VPC + Subnets
# ----------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ----------------------------
# Security Groups (SAFE, NO REPLACEMENT)
# ----------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "strapi-ec2-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

  lifecycle {
    ignore_changes = [
      description,
      tags,
      tags_all,
      ingress,
      egress
    ]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "strapi-rds-sg"
  vpc_id = data.aws_vpc.default.id

  lifecycle {
    ignore_changes = [
      description,
      tags,
      tags_all,
      ingress,
      egress
    ]
  }

  ingress {
    description     = "Postgres from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ----------------------------
# DB Subnet Group
# ----------------------------
resource "aws_db_subnet_group" "strapi_db_subnets" {
  name       = "strapi-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

# ----------------------------
# Secrets
# ----------------------------
resource "random_password" "db_password" {
  length  = 16
  special = false
}

resource "random_password" "admin_jwt" {
  length = 32
}

resource "random_password" "api_token_salt" {
  length = 32
}

resource "random_password" "transfer_token_salt" {
  length = 32
}

resource "random_password" "encryption_key" {
  length = 32
}

resource "random_password" "admin_auth_secret" {
  length = 32
}

resource "random_password" "jwt_secret" {
  length = 32
}

resource "random_password" "app_keys" {
  length = 64
}

resource "random_id" "id_suffix" {
  byte_length = 4
}

locals {
  db_password_final   = random_password.db_password.result
  db_identifier_final = "strapi-postgres-${random_id.id_suffix.hex}"
}

# ----------------------------
# RDS Instance
# ----------------------------
resource "aws_db_instance" "strapi_db" {
  identifier             = local.db_identifier_final
  engine                 = "postgres"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = var.db_storage_type
  username               = var.db_username
  password               = local.db_password_final
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.strapi_db_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true
  apply_immediately   = true
}

# ----------------------------
# AMI Lookup
# ----------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ----------------------------
# EC2 Instance
# ----------------------------
resource "aws_instance" "strapi" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name

  depends_on = [aws_db_instance.strapi_db]

  user_data = templatefile("${path.module}/user_data.sh", {
    strapi_image        = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/strapi:${var.image_tag}"
    db_host             = aws_db_instance.strapi_db.address
    db_port             = aws_db_instance.strapi_db.port
    db_name             = var.db_name
    db_username         = var.db_username
    db_password         = local.db_password_final
    admin_jwt           = random_password.admin_jwt.result
    admin_auth_secret   = random_password.admin_auth_secret.result
    jwt_secret          = random_password.jwt_secret.result
    app_keys            = random_password.app_keys.result
    api_token_salt      = random_password.api_token_salt.result
    transfer_token_salt = random_password.transfer_token_salt.result
    encryption_key      = random_password.encryption_key.result
    node_env            = var.node_env
    aws_region          = var.aws_region
    ecr_token           = var.ecr_token
  })

  tags = { Name = "strapi-ec2" }
}
