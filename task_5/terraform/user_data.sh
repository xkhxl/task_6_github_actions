#!/bin/bash
set -xe

yum update -y
yum install -y docker awscli

systemctl enable --now docker
usermod -aG docker ec2-user

# ECR repo domain extracted from strapi_image
ECR_DOMAIN=$(echo ${strapi_image} | cut -d'/' -f1)

# Login using token passed by Terraform (since IAM is restricted)
echo "${ecr_token}" | docker login --username AWS --password-stdin ${strapi_image}

# Pull image
docker pull ${strapi_image}

# Run container
docker run -d --restart always --name strapi \
  -p 80:1337 \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_HOST="${db_host}" \
  -e DATABASE_PORT="${db_port}" \
  -e DATABASE_NAME="${db_name}" \
  -e DATABASE_USERNAME="${db_username}" \
  -e DATABASE_PASSWORD="${db_password}" \
  -e DATABASE_SSL=true \
  -e DATABASE_SSL_REJECT_UNAUTHORIZED=false \
  -e API_TOKEN_SALT="${api_token_salt}" \
  -e TRANSFER_TOKEN_SALT="${transfer_token_salt}" \
  -e ENCRYPTION_KEY="${encryption_key}" \
  -e ADMIN_AUTH_SECRET="${admin_auth_secret}" \
  -e NODE_ENV="${node_env}" \
  -e ADMIN_JWT_SECRET="${admin_jwt}" \
  -e APP_KEYS="${app_keys}" \
  -e JWT_SECRET="${jwt_secret}" \
  ${strapi_image}
