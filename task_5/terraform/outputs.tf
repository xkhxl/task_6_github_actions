# outputs.tf
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.strapi_db.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.strapi_db.port
}

output "rds_db_name" {
  description = "RDS database name"
  value       = aws_db_instance.strapi_db.db_name
}

output "ec2_public_ip" {
  description = "Public IP of Strapi EC2"
  value       = aws_instance.strapi.public_ip
}

output "strapi_url" {
  description = "Strapi URL"
  value       = "http://${aws_instance.strapi.public_ip}/admin"
}
