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

```
Internet → ALB → ECS Service (Fargate) → Flask App Container
                     ↓
                 ECR Repository
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 0.12.0
- AWS CLI configured with appropriate credentials
- Docker (for building and pushing container images)
- Terraform Cloud account (configured for remote state)
- Access to the "adco" organization workspace "devops-assessment-terraform" in Terraform Cloud

## Project Structure

```
├── .gitignore                 # Git ignore rules for Terraform
├── README.md                  # This file
└── envs/
    └── dev/                   # Development environment
        ├── .terraform.lock.hcl # Provider version locks
        ├── main.tf            # Provider and backend configuration
        ├── variables.tf       # Input variables
        ├── data.tf           # Data sources
        ├── ecs.tf            # ECS cluster, service, and task definition
        ├── alb.tf            # Application Load Balancer configuration
        ├── ecr.tf            # ECR repository
        └── sg.tf             # Security groups
```

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd tp-tf-assessment
```

### 2. Configure Variables

Update the variables in `envs/dev/variables.tf` or create a `terraform.tfvars` file:

```hcl
project_name = "your-project-name"
container_image = "your-account-id.dkr.ecr.eu-west-2.amazonaws.com/your-app:latest"
```

### 3. Initialize Terraform

```bash
cd envs/dev
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
terraform output alb_dns_name
```

## Configuration

### Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `project_name` | Name of the project (used for resource naming) | `string` | `"simhill"` |
| `container_image` | Container image URI from ECR | `string` | `"946760796955.dkr.ecr.eu-west-2.amazonaws.com/flask-tp-app:latest"` |

### Environment Variables

The Flask application is configured with:
- `FLASK_APP=hello`
- `FLASK_ENV=production`

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

## Deployment Pipeline

### Container Image Workflow

1. Build your Flask application Docker image
2. Tag the image: `docker tag your-app:latest <account-id>.dkr.ecr.eu-west-2.amazonaws.com/flask-tp-app:latest`
3. Push to ECR: `docker push <account-id>.dkr.ecr.eu-west-2.amazonaws.com/flask-tp-app:latest`
4. Update the `container_image` variable
5. Run `terraform apply`

### ECR Commands

```bash
# Get login token
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-west-2.amazonaws.com

# Build and tag
docker build -t flask-tp-app .
docker tag flask-tp-app:latest <account-id>.dkr.ecr.eu-west-2.amazonaws.com/flask-tp-app:latest

# Push
docker push <account-id>.dkr.ecr.eu-west-2.amazonaws.com/flask-tp-app:latest
```

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

### Debugging Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster simhill-cluster --services simhill-service

# View ECS service events
aws ecs describe-services --cluster simhill-cluster --services simhill-service --query 'services[0].events'

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## Cost Optimization

- **ECS Fargate**: 2 tasks × 0.25 vCPU × 0.5 GB RAM
- **ALB**: Application Load Balancer with minimal traffic
- **ECR**: Pay per storage used

Estimated monthly cost: ~$15-25 USD (varies by usage)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review AWS documentation
3. Open an issue in this repository

## Changelog

### v1.0.0
- Initial release with basic ECS Fargate deployment
- ALB integration
- ECR repository setup
- Security group configuration