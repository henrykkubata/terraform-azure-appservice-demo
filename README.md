Terraform Azure App Service Demo

Project Description:
A demo Go application running on Azure App Service, integrated with PostgreSQL Flexible Server and Private Endpoint, deployed via Terraform and containerized with Docker.
Supports multiple environments (dev, staging, production) and CI/CD using GitHub Actions.

Requirements:
- Terraform 1.8+
- Go 1.20+
- Docker
- Azure CLI
- Azure account with sufficient permissions

Local Run:
docker compose up

Application will be available at http://localhost:3000

Endpoints:
- GET /items         List items
- POST /items?name=foo  Add an item
- DELETE /items      Clear all items

Docker:
Build and run container:
docker build -t demo-go-app:latest ./docker
docker run -p 3000:3000 demo-go-app:latest

Terraform:

Initialize:
cd infra/terraform
terraform init

Plan:
terraform plan -var-file="dev.tfvars"

Apply:
terraform apply -auto-approve -var-file="dev.tfvars"

Destroy Infrastructure:
terraform destroy -var-file="dev.tfvars"

CI/CD with GitHub Actions:
The workflow automates:
1. Build and push Docker image to Azure Container Registry (ACR)
2. Deploy Terraform infrastructure
3. Deploy application to Azure App Service
4. Run a simple health check

Required GitHub Secrets:
- AZURE_CREDENTIALS       JSON from Azure Service Principal
- AZURE_CLIENT_ID         from Service Principal
- AZURE_CLIENT_SECRET     from Service Principal
- AZURE_SUBSCRIPTION_ID   Azure subscription ID
- AZURE_TENANT_ID         from Service Principal
- ACR_USERNAME            ACR username (`az acr credential show`)
- ACR_PASSWORD            ACR password (`az acr credential show`)

License:
MIT © Henryk Kubata
