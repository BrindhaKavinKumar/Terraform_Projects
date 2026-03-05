# Terraform AWS Project: VPC + 2 Public Subnets + 2 EC2 + ALB + S3

This Terraform project creates a basic AWS web infrastructure with:
- 1 VPC
- 2 Public Subnets (two AZs)
- Internet Gateway + Route Table (public routing)
- Security Group (HTTP + SSH)
- 2 EC2 instances (each in a different subnet, configured with user-data)
- Application Load Balancer (ALB) routing traffic to both instances
- 1 S3 Bucket
- Output: ALB DNS name

---

## Architecture Overview

**Flow:**
Internet → **ALB (HTTP :80)** → **Target Group** → **EC2 Instance 1 & 2**

**Networking:**
- VPC `10.0.0.0/16`
- Subnet1 `10.0.0.0/24` in `eu-central-1a`
- Subnet2 `10.0.1.0/24` in `eu-central-1b`
- Internet Gateway attached
- Route table with `0.0.0.0/0` → IGW associated to both subnets

---

## Prerequisites

- AWS account
- Terraform installed
- AWS CLI installed and configured

### Configure AWS CLI
```bash
aws configure
