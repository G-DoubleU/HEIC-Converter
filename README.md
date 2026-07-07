# HEIC to JPG Converter

A serverless HEIC to JPG converter using Azure Functions, FastAPI, Azure infra with Terraform

## Architecture

- **FastAPI app** (`api/`) Basic WebUI and API sending/retrieving the HEIC/JPG file from Azure 
- **Azure Function** (`functions/`) is triggered by Event Grid when a file lands in storage, converts it to JPG
- **Terraform** (`infrastructure/`) provisions all Azure resources

## Prerequisites

- An Azure subscription
- Terraform 1.6 or newer, Azure CLI, Azure Functions Core Tools
- Python 3.13

## Setup

```bash
git clone
cd HEIC-Converter
az login
az account set --subscription "<subscription-id>"\
```

Configure variables:
``` bash
cd infrastructure/core
cp terraform.tfvars.example terraform.tfvars
# Set subscription_id, resource_prefix (for naming), and location 
``` 

Repeat for infrastructure/wiring 

If using remote state, update backend.tf

## Deployment 

```bash
# Apply core infra 
cd infrastructure/core
terraform init && terraform apply 

# Deploy the function 
cd ../../functions
python3.13 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
func azure functionapp publish $(cd ../infrastructure/core && terraform output -raw function_app_name) --python

# Deploy te API
cd ../api
rm -f ../api.zip
zip -r ../api.zip . -x ".venv/*" "__pycache__/*" "*.pyc" ".git/*" ".env"
az webapp deploy \
  --resource-group $(cd ../infrastructure/core && terraform output -raw resource_group_name) \
  --name $(cd ../infrastructure/core && terraform output -raw web_app_service_name) \
  --src-path ../api.zip --type zip
```
# Apply wiring 
```bash
cd ../infrastrucutre/wiring
terraform init && terraform apply 
``` 
## Notes
- CLI will show a 504 error on the API deploy because pillow-heif takes longer to build than the gateway will wait
- Storage account access uses connection strings rather than managed identity due to a known issue with AzureRM 's Flex Consumption resource

