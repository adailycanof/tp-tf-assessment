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
envs/dev/
├── alb.tf                 # Application Load Balancer configuration
├── data.tf                # Data sources (VPC, subnets, IAM roles)
├── ecr.tf                 # Elastic Container Registry
├── ecs.tf                 # ECS cluster, service, and task definition
├── main.tf                # Provider and Terraform configuration
├── outputs.tf             # Output values
├── sg.tf                  # Security groups
├── variables.tf           # Variable definitions
└── terraform.tfvars       # Variable values (environment-specific)
```

## Configuration

### terraform.tfvars

The `terraform.tfvars` file contains all environment-specific configuration. Key variables include:

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `project_name` | Name of the project | `simhill` |
| `environment` | Environment name (dev, staging, prod) | `dev` |
| `aws_region` | AWS region for deployment | `eu-centra1-1` |
| `container_image` | Full ECR image URI | `946760796955.dkr.ecr.eu-centra1-1.amazonaws.com/flask-tp-app:latest` |
| `ecs_cpu` | CPU units for ECS tasks | `256` |
| `ecs_memory` | Memory (MB) for ECS tasks | `512` |
| `ecs_desired_count` | Number of running tasks | `2` |
| `container_port` | Port the container listens on | `5000` |
| `alb_port` | Load balancer port | `80` |

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd tp-tf-assessment
```

### 2. Initialize Terraform

```bash
cd envs/dev
terraform init
```

### 3. Plan and Apply

```bash
terraform plan
terraform apply
```

### 4. Access Your Application

After deployment, get the ALB DNS name:

```bash
terraform output alb_dns_name
```

## Configuration

### Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `project_name` | Name of the project (used for resource naming) | `string` | `"simhill"` |
| `container_image` | Container image URI from ECR | `string` | `"946760796955.dkr.ecr.eu-centra1-1.amazonaws.com/flask-tp-app:latest"` |

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

### Manual Container Image Workflow

1. Build your Flask application Docker image
2. Tag the image: `docker tag your-app:latest <account-id>.dkr.ecr.eu-centra1-1.amazonaws.com/flask-tp-app:latest`
3. Push to ECR: `docker push <account-id>.dkr.ecr.eu-centra1-1.amazonaws.com/flask-tp-app:latest`
4. Update the `container_image` variable
5. Run `terraform apply`

### ECR Commands

```bash
# Get login token
aws ecr get-login-password --region eu-centra1-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-centra1-1.amazonaws.com

# Build and tag
docker build -t flask-tp-app .
docker tag flask-tp-app:latest <account-id>.dkr.ecr.eu-centra1-1.amazonaws.com/flask-tp-app:latest

# Push
docker push <account-id>.dkr.ecr.eu-centra1-1.amazonaws.com/flask-tp-app:latest
```

### Automated Container Image Workflow

Please refer to the `adailycanof/tp-gha-assessment` repo in github for the full automated build and push of the image to ECR.

## Outputs

After deployment, useful outputs include:

- `alb_dns_name` - Load balancer DNS name
- `alb_zone_id` - Load balancer Route53 zone ID
- `ecr_repository_url` - ECR repository URL
- `ecs_cluster_name` - ECS cluster name
- `ecs_service_name` - ECS service name
- `application_url` - Full application URL

## Security

### Security Groups

- **ALB Security Group**: Allows inbound HTTP (port 80) from anywhere
- **ECS Tasks Security Group**: Allows inbound traffic on container port (5000) from ALB only

### IAM Roles

- **ECS Task Execution Role**: Allows ECS to pull images from ECR and write logs to CloudWatch

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
aws ecs describe-services --cluster <clsuter-name> --services <service-name>

# View ECS service events
aws ecs describe-services --cluster <clsuter-name> --services <service-name> --query 'services[0].events'

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## Cost Optimization

- **ECS Fargate**: 2 tasks × 0.25 vCPU × 0.5 GB RAM
- **ALB**: Application Load Balancer with minimal traffic
- **ECR**: Pay per storage used

Estimated monthly cost: ~$15-25 USD (varies by usage)

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note**: This will permanently delete all infrastructure resources. Ensure you have backups of any important data.

## Contributing

1. Make changes to the appropriate `.tf` files
2. Update `terraform.tfvars` if new variables are added
3. Test changes with `terraform plan`
4. Update this README if architectural changes are made

## Tags and Resource Naming

All resources are tagged with:
- `Environment` - The deployment environment
- `Project` - The project name
- `ManagedBy` - "terraform"

Resource names follow the pattern: `{project_name}-{environment}-{resource_type}`

## Improvements

- Security Enhancements - Including HTTPS/TLS, WAF, secrets management, and proper VPC setup
- Infrastructure & Architecture - Multi-AZ deployment, auto-scaling, database integration, and CDN
- Monitoring & Observability - CloudWatch dashboards, centralized logging, and APM
- CI/CD & Deployment - Blue/green deployments, infrastructure pipelines, and automated testing
- Operational Excellence - Backup strategies, compliance frameworks, and better documentation
- Performance & Scalability - Load testing, container optimization, and database improvements

## IAM Permissions Needed

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2VPCPermissions",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DescribeTags"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "eu-central-1"
        }
      }
    },
    {
      "Sid": "ECRAuthenticationGlobal",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ECSPermissions",
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeleteCluster",
        "ecs:DescribeClusters",
        "ecs:RegisterTaskDefinition",
        "ecs:DeregisterTaskDefinition",
        "ecs:DescribeTaskDefinition",
        "ecs:ListTaskDefinitions",
        "ecs:CreateService",
        "ecs:UpdateService",
        "ecs:DeleteService",
        "ecs:DescribeServices",
        "ecs:ListServices",
        "ecs:ListTagsForResource",
        "ecs:TagResource",
        "ecs:UntagResource"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "eu-central-1"
        }
      }
    },
    {
      "Sid": "ECRPermissions",
      "Effect": "Allow",
      "Action": [
        "ecr:CreateRepository",
        "ecr:DeleteRepository",
        "ecr:DescribeRepositories",
        "ecr:GetRepositoryPolicy",
        "ecr:SetRepositoryPolicy",
        "ecr:DeleteRepositoryPolicy",
        "ecr:PutImageScanningConfiguration",
        "ecr:GetImageScanningConfiguration",
        "ecr:ListTagsForResource",
        "ecr:TagResource",
        "ecr:UntagResource",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage",
        "ecr:BatchDeleteImage",
        "ecr:DescribeImages",
        "ecr:ListImages"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "eu-central-1"
        }
      }
    },
    {
      "Sid": "LoadBalancerPermissions",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:DescribeTags"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "eu-central-1"
        }
      }
    },
    {
      "Sid": "IAMPermissions",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:UpdateRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:PassRole",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:ListRoleTags",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:GetInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchLogsPermissions",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:DeleteLogGroup",
        "logs:DescribeLogGroups",
        "logs:PutRetentionPolicy",
        "logs:DeleteRetentionPolicy",
        "logs:TagLogGroup",
        "logs:UntagLogGroup",
        "logs:ListTagsLogGroup",
        "logs:CreateLogStream",
        "logs:DeleteLogStream",
        "logs:DescribeLogStreams"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "eu-central-1"
        }
      }
    },
    {
      "Sid": "ApplicationAutoScalingPermissions",
      "Effect": "Allow",
      "Action": [
        "application-autoscaling:RegisterScalableTarget",
        "application-autoscaling:DeregisterScalableTarget",
        "application-autoscaling:DescribeScalableTargets",
        "application-autoscaling:PutScalingPolicy",
        "application-autoscaling:DeleteScalingPolicy",
        "application-autoscaling:DescribeScalingPolicies"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "eu-central-1"
        }
      }
    }
  ]
}
```