# Deployment Guide

## Prerequisites
- Terraform >= 1.0
- AWS CLI configured
- Docker for image building
- Access to Terraform Cloud workspace

## Deployment Steps

### 1. Environment Setup
```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Plan Deployment
```bash
terraform plan
```

### 4. Apply Changes
```bash
terraform apply
```

## Adding New Environments
1. Create new directory under `environments/`
2. Copy `main.tf` and `variables.tf` from dev
3. Create environment-specific `terraform.tfvars`
4. Update Terraform Cloud workspace name
