# ETL Infrastructure Modules

This directory contains the modular Terraform infrastructure for the ETL pipeline on Google Cloud Platform.

## Module Structure

```
modules/
├── foundation/           # API enablement and project setup
├── networking/          # VPC, subnets, NAT gateway, firewall rules
├── iam/                # Service accounts and IAM role assignments
├── security/           # Secret Manager and security resources
├── storage/            # GCS buckets for data lake and staging
├── database/           # Cloud SQL PostgreSQL instance
├── compute/            # Dataproc cluster for Spark processing
├── analytics/          # BigQuery datasets for analytics
└── orchestration/      # Cloud Composer environment
```

## Module Dependencies

```
foundation → networking → iam → security
                     ↓         ↓
                 storage → database → compute → analytics → orchestration
```

## Usage

From the root directory:

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -var-file="terraform.tfvars"

# Apply the infrastructure
terraform apply -var-file="terraform.tfvars"
```

## Module Benefits

1. **Modularity**: Each module has a single responsibility
2. **Reusability**: Modules can be reused across environments
3. **Maintainability**: Easier to update and debug specific components
4. **Testing**: Individual modules can be tested independently
5. **Parallel Development**: Teams can work on different modules

## Migration from Monolithic

The original `main.tf` has been refactored into these modules while maintaining the same functionality and resource relationships.

## Environment Configuration

Each module accepts environment-specific variables, allowing the same modules to be used across dev, staging, and production environments with different configurations. 