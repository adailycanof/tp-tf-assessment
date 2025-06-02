# Architecture Documentation

## Overview
This document describes the architecture of the Flask application infrastructure deployed on AWS.

## Components
- **ECS Fargate**: Serverless container orchestration
- **Application Load Balancer**: Traffic distribution and SSL termination
- **ECR**: Container image registry
- **CloudWatch**: Logging and monitoring
- **Security Groups**: Network security

## Network Architecture
```
Internet → ALB → ECS Service (Fargate) → Flask App Container
                     ↓
                 ECR Repository
```

## Security Considerations
- ALB security group allows HTTP/HTTPS from internet
- ECS tasks security group only allows traffic from ALB
- All resources are tagged for cost tracking and compliance
