# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  default     = "301782007642"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_root_volume_gb" {
  description = "EC2 root volume size (GB)"
  type        = number
  default     = 30
}

variable "key_name" {
  description = "Existing EC2 key pair name (optional)"
  type        = string
  default     = ""
}

variable "strapi_image" {
  description = "Docker image to run (ECR or Docker Hub full name)"
  type        = string
  default     = ""
}

variable "image_tag" {
  type    = string
  default = "latest"
}


# DB variables
variable "db_identifier" {
  description = "RDS DB identifier (optional)"
  type        = string
  default     = ""
}

variable "db_engine_version" {
  description = "Postgres engine version"
  type        = string
  default     = "15.14"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage (GB)"
  type        = number
  default     = 20
}

variable "db_storage_type" {
  description = "RDS storage type"
  type        = string
  default     = "gp3"
}

variable "db_name" {
  description = "Database name for Strapi"
  type        = string
  default     = "strapi"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "strapi"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "node_env" {
  description = "NODE_ENV for Strapi container"
  type        = string
  default     = "production"
}

variable "ecr_token" {
  description = "Temporary ECR login token"
  type        = string
  sensitive   = true
}
