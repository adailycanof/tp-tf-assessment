# Flask Application Infrastructure on AWS

This repository contains Terraform Infrastructure as Code (IaC) for deploying a Flask application on AWS using ECS Fargate, Application Load Balancer, and ECR.

## Architecture Overview

The infrastructure deploys a containerized Flask application with the following AWS services:

- **ECS Fargate**: Serverless container orchestration
- **Application Load Balancer (ALB)**: Load balancing and traffic distribution
- **ECR**: Container image registry
- **VPC**: Network isolation using default VPC
- **Security Groups**: Network security controls
- **IAM Roles**: Service permissions
- **CloudWatch**: Logging and monitoring

```
Internet → ALB → ECS Service (Fargate) → Flask App Container
                     ↓
                 ECR Repository
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- AWS CLI configured with appropriate credentials
- Docker (for building and pushing container images)
- Terraform Cloud account (configured for remote state)
- Access to the "adco" organization workspace "devops-assessment-terraform-dev" in Terraform Cloud

## Project Structure

```
├── README.md
├── .gitignore
│
├── environments/                   # Environment-specific configurations
│   ├── dev/
│   │   ├── main.tf                # Environment entry point and module call
│   │   ├── variables.tf           # Environment variable definitions
│   │   ├── terraform.tfvars       # Environment-specific values (gitignored)
│   │   └── terraform.tfvars.example # Template for variable values
│   ├── staging/                   # Future staging environment
│   └── prod/                      # Future production environment
│
├── modules/                       # Reusable Terraform modules
│   └── flask-app/
│       ├── main.tf               # Module entry point (optional)
│       ├── variables.tf          # Module input variables
│       ├── outputs.tf            # Module outputs
│       ├── locals.tf             # Local values and computed data
│       ├── versions.tf           # Provider version constraints
│       ├── data.tf               # Data sources (VPC, subnets, IAM roles)
│       ├── ecs.tf                # ECS cluster, service, and task definition
│       ├── alb.tf                # Application Load Balancer configuration
│       ├── ecr.tf                # Elastic Container Registry
│       └── security_groups.tf    # Security groups configuration
│
└── docs/                         # Documentation
    ├── architecture.md           # Architecture documentation
    └── deployment.md             # Deployment procedures
```

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd tp-tf-assessment
```

### 2. Configure Environment

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan and Apply

```bash
terraform plan
terraform apply
```

### 5. Access Your Application

After deployment, get the ALB DNS name:

```bash
terraform output application_url
```

## Configuration

### Key Variables

| Variable | Description | Default Value | Required |
|----------|-------------|---------------|----------|
| `project_name` | Name of the project | `"simhill"` | Yes |
| `environment` | Environment name | `"dev"` | Yes |
| `aws_region` | AWS region for deployment | `"eu-central-1"` | Yes |
| `container_image` | Full ECR image URI | See example | Yes |
| `ecs_cpu` | CPU units for ECS tasks | `256` | No |
| `ecs_memory` | Memory (MB) for ECS tasks | `512` | No |
| `ecs_desired_count` | Number of running tasks | `2` | No |
| `container_port` | Container application port | `5000` | No |
| `alb_port` | Load balancer port | `80` | No |

### Environment Variables

The Flask application is configured with:
- `FLASK_APP=hello`
- `FLASK_ENV=production` (for prod) or environment name

## Module Usage

The infrastructure is organized as a reusable module. Each environment calls the module with environment-specific parameters:

```hcl
module "flask_app" {
  source = "../../modules/flask-app"
  
  project_name     = "simhill"
  environment      = "dev"
  aws_region      = "eu-central-1"
  container_image = "946760796955.dkr.ecr.eu-central-1.amazonaws.com/flask-tp-app:latest"
  
  # Additional configuration...
  common_tags = {
    Environment = "dev"
    Project     = "simhill"
    ManagedBy   = "terraform"
  }
}
```

## Security

### Security Groups

- **ALB Security Group**: Allows inbound traffic on port 80 from anywhere
- **ECS Tasks Security Group**: Allows inbound traffic on port 5000 from ALB only

### IAM Roles

- **ECS Task Execution Role**: Minimal permissions for ECS to pull images and write logs

## Monitoring and Health Checks

- **Health Check Path**: `/`
- **Health Check Interval**: 30 seconds
- **Healthy Threshold**: 2 consecutive successful checks
- **Unhealthy Threshold**: 2 consecutive failed checks
- **CloudWatch Logs**: Centralized logging for ECS tasks

## Adding New Environments

To add a new environment (e.g., staging):

1. Create a new directory: `environments/staging/`
2. Copy files from `environments/dev/`
3. Update `terraform.tfvars` with staging-specific values
4. Update the Terraform Cloud workspace name in `main.tf`
5. Run `terraform init` and `terraform apply`

## Deployment Pipeline

### Manual Container Image Workflow

1. Build your Flask application Docker image
2. Tag the image: `docker tag your-app:latest <account-id>.dkr.ecr.eu-central-1.amazonaws.com/flask-tp-app:latest`
3. Push to ECR: `docker push <account-id>.dkr.ecr.eu-central-1.amazonaws.com/flask-tp-app:latest`
4. Update the `container_image` variable in `terraform.tfvars`
5. Run `terraform apply`

### ECR Commands

```bash
# Get login token
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-central-1.amazonaws.com

# Build and tag
docker build -t flask-tp-app .
docker tag flask-tp-app:latest <account-id>.dkr.ecr.eu-central-1.amazonaws.com/flask-tp-app:latest

# Push
docker push <account-id>.dkr.ecr.eu-central-1.amazonaws.com/flask-tp-app:latest
```

### Automated Container Image Workflow

Please refer to the `adailycanof/tp-gha-assessment` repo in GitHub for the full automated build and push of the image to ECR.

## Outputs

After deployment, the following outputs are available:

| Output | Description |
|--------|-------------|
| `application_url` | Full application URL |
| `alb_dns_name` | Load balancer DNS name |
| `alb_zone_id` | Load balancer Route53 zone ID |
| `ecr_repository_url` | ECR repository URL |
| `ecs_cluster_name` | ECS cluster name |
| `ecs_service_name` | ECS service name |

## Troubleshooting

### Common Issues

1. **ECS Service fails to start**
   - Check ECR image exists and is accessible
   - Verify security group rules
   - Check ECS service logs in CloudWatch

2. **ALB health checks failing**
   - Ensure your Flask app responds on port 5000
   - Verify the health check path returns HTTP 200
   - Check container port mapping

3. **Terraform state issues**
   - Ensure Terraform Cloud workspace is properly configured
   - Check AWS credentials and permissions

4. **Module not found errors**
   - Verify the module path in `main.tf` is correct
   - Ensure all module files are present

### Debugging Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster <cluster-name> --services <service-name>

# View ECS service events
aws ecs describe-services --cluster <cluster-name> --services <service-name> --query 'services[0].events'

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# View CloudWatch logs
aws logs get-log-events --log-group-name /ecs/<project>-<env> --log-stream-name <stream-name>
```

## Cost Optimization

- **ECS Fargate**: 2 tasks × 0.25 vCPU × 0.5 GB RAM
- **ALB**: Application Load Balancer with minimal traffic
- **ECR**: Pay per storage used
- **CloudWatch**: Pay per log ingestion and storage

Estimated monthly cost: ~$15-25 USD (varies by usage)

## Cleanup

To destroy all resources:

```bash
cd environments/dev
terraform destroy
```

**Note**: This will permanently delete all infrastructure resources. Ensure you have backups of any important data.

## Best Practices Implemented

### Terraform Best Practices
- **Modular Structure**: Reusable modules for different environments
- **Variable Validation**: Input validation for all variables
- **Consistent Naming**: Standardized resource naming using locals
- **Provider Versioning**: Pinned provider versions for consistency
- **State Management**: Remote state using Terraform Cloud
- **Documentation**: Comprehensive inline and external documentation

### AWS Best Practices
- **Security Groups**: Principle of least privilege
- **IAM Roles**: Minimal required permissions
- **Tagging Strategy**: Consistent resource tagging
- **Health Checks**: Robust application health monitoring
- **Logging**: Centralized logging with CloudWatch

### DevOps Best Practices
- **Environment Separation**: Clear environment boundaries
- **Configuration Management**: Environment-specific configurations
- **Version Control**: Proper .gitignore and file organization
- **Documentation**: Architecture and deployment documentation

## Resource Naming Convention

All resources follow the pattern: `{project_name}-{environment}-{resource_type}`

Examples:
- ECS Cluster: `simhill-dev-cluster`
- ALB: `simhill-dev-alb`
- Security Group: `simhill-dev-alb-sg`

## Tags and Compliance

All resources are tagged with:
- `Environment` - The deployment environment (dev/staging/prod)
- `Project` - The project name
- `ManagedBy` - "terraform"
- `Owner` - Team or individual responsible
- `CostCenter` - For cost allocation

## Future Improvements

- Enable HTTPS via ALB and integrate AWS WAF
- Ensure high availability with multi-AZ setup
- Set up CloudWatch dashboards and custom alarms
- Use Terratest for infrastructure testing
- Automate security scanning in the pipeline
- Identify and apply cost optimization opportunities