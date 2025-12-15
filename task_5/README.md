# Task 5 - Strapi Deployment on AWS EC2 Using Docker & Terraform

This project deploys a fully containerized Strapi application on an AWS EC2 instance using Terraform automation.

## Steps Implemented
- Strapi containerized with Docker
- Image pushed to Docker Hub
- Terraform provisions EC2, Security Group, and storage
- User Data installs Docker and runs the Strapi container automatically
- Access Strapi at `http://<ec2-public-ip>/admin`

---

## Docker Build and Push
```bash
docker build -t strapi-local .
docker tag strapi-local <dockerhub-username>/strapi-ec2:latest
docker push <dockerhub-username>/strapi-ec2:latest
```

---

## Terraform Deploy
```bash
terraform init
terraform plan
terraform apply -auto-approve
```
After apply completes, Terraform outputs:
```bash
strapi_url = "http://<public-ip>/admin"
```
To destroy the resources, use `terraform destroy -auto-approve`.

---