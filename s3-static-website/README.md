# Terraform S3 Static Website

This project uses Terraform to host a static website on AWS S3.

## Resources Created

- S3 Bucket
- Static Website Hosting
- Bucket Policy for public access

## Files

- main.tf – Terraform resources
- provider.tf – AWS provider configuration
- variables.tf – Variables used in the project
- index.html – Website home page
- error.html – Error page
- lily.png – Image used in website

## How to Deploy

1. Initialize Terraform

terraform init

2. Check the plan

terraform plan

3. Apply the configuration

terraform apply

## Result

After deployment, the website will be accessible through the S3 website endpoint.
