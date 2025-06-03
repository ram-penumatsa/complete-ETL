# Complete ETL Infrastructure Deployment

This folder contains a **comprehensive Terraform configuration** that deploys a complete ETL pipeline infrastructure on Google Cloud Platform in a single deployment.

## 🏗️ **Infrastructure Components**

This configuration creates:

- **Custom VPC**: Secure network with public and private subnets
- **Google Cloud Storage (GCS)**: Data lake and staging buckets
- **Cloud SQL PostgreSQL**: Managed database in private subnet
- **Dataproc Cluster**: Scalable Spark processing in private subnet
- **BigQuery Dataset**: Data warehouse for analytics
- **Cloud Composer**: Managed Airflow in public subnet
- **NAT Gateway**: Internet access for private subnet resources
- **Firewall Rules**: Secure network access controls
- **IAM & Service Accounts**: Automated security configuration

## 📋 **Prerequisites**

### Required Tools
- **Terraform** (v1.0+)
- **Google Cloud SDK** (`gcloud` CLI)
- **GCP Project** with billing enabled
- **Project Owner** or **Editor** permissions

### Authentication Setup
```bash
# Authenticate with Google Cloud
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# Set up application default credentials for Terraform
gcloud auth application-default login
```

## ⚙️ **Configuration**

### 1. Update Project Settings
Edit `terraform.tfvars` and update the following values:

```hcl
# Update with your project ID
project_id = "your-project-id"

# Update with a globally unique bucket name
data_bucket_name = "your-project-id-etl-data-lake"
```

### 2. Set Secure Password
**Important**: The password is now securely stored in Google Cloud Secret Manager. Set the password as an environment variable only during deployment:

```bash
export TF_VAR_sql_user_password="YourSecurePassword123!"
```

**Security Benefits**:
- ✅ Password stored securely in Google Secret Manager
- ✅ Automatic encryption at rest and in transit
- ✅ IAM-controlled access to secrets
- ✅ No password exposure in environment variables during runtime
- ✅ Centralized secret management and rotation capabilities

After deployment, the password is only accessible through Secret Manager with proper IAM permissions.

### 3. Review Regional Settings
The default configuration uses:
- **Data processing**: `asia-south1` (Dataproc, Cloud SQL, GCS)
- **Orchestration**: `us-central1` (Cloud Composer)
- **Analytics**: `US` (BigQuery)

Update these in `terraform.tfvars` if needed.

## 🚀 **Deployment**

### Quick Start with Enhanced Deployment Script

The project now includes an enhanced deployment script that handles:
- ✅ Prerequisites validation
- ✅ Secret management setup
- ✅ File uploads and verification
- ✅ Deployment validation
- ✅ Comprehensive next steps

```bash
# 1. Set environment variables
export TF_VAR_project_id="your-gcp-project-id"
export TF_VAR_environment="dev"
export TF_VAR_sql_user_password="YourSecurePassword123!"

# 2. Initialize and deploy infrastructure
terraform init
terraform plan
terraform apply

# 3. Deploy application components with enhanced script
./deploy.sh

# 4. Validate deployment (optional)
./scripts/validate_deployment.sh
```

### Detailed Deployment Steps

#### Step 1: Initialize Terraform
```bash
terraform init
```

#### Step 2: Plan Deployment
```bash
terraform plan
```

#### Step 3: Deploy Infrastructure
```bash
terraform apply
```

**Note**: Deployment takes approximately **20-30 minutes**, with Cloud Composer being the longest component to provision.

#### Step 4: Deploy Application Components

The enhanced deployment script (`./deploy.sh`) provides:

**🔍 Prerequisites Validation**:
- Checks required tools (terraform, gcloud, gsutil)
- Validates authentication status
- Verifies Terraform state exists
- Confirms password configuration

**📊 Infrastructure Validation**:
- Retrieves Terraform outputs
- Validates GCS bucket access
- Checks Secret Manager configuration
- Verifies IAM permissions

**📁 Organized File Upload**:
- Sample data files with progress tracking
- JAR dependencies with verification
- PySpark jobs including database utilities
- Airflow DAGs
- Documentation and management scripts

**✅ Deployment Verification**:
- Bucket contents validation
- Secret Manager status check
- Upload confirmation
- Component health checks

```bash
# Run the enhanced deployment script
./deploy.sh
```

**Sample Output**:
```
==================================================
ETL Project Deployment Script
Environment: dev
==================================================

=== Validating Prerequisites ===
✅ Required tools are available
✅ gcloud authentication verified
✅ Terraform state found
✅ Database password configured

=== Retrieving Terraform Outputs ===
✅ Data Bucket: my-project-etl-data-lake
✅ Composer Bucket: us-central1-my-composer-bucket
✅ Project ID: my-gcp-project
✅ Secret Manager Secret: dev-sql-password

=== Validating Secret Management Setup ===
✅ Secret Manager secret exists and is accessible
✅ Secret has 1 version(s)
✅ Secret management script is available and executable

=== Uploading Sample Data Files ===
✅ Sample data uploaded (5 files)

=== Uploading JAR Dependencies ===
✅ postgresql JAR uploaded successfully
✅ spark-bigquery JAR uploaded successfully

=== Uploading Database Utilities ===
✅ Database utilities uploaded

=== Uploading PySpark Jobs ===
✅ PySpark jobs uploaded (2 files)
✅ Main analytics job (sales_analytics_direct.py) uploaded
✅ Database utilities (database_utils.py) uploaded

=== Uploading Airflow DAGs ===
✅ Airflow DAGs uploaded (1 files)
✅ Main ETL DAG (sales_etl_dag.py) uploaded

=== Uploading Documentation ===
✅ Uploaded README.md
✅ Uploaded SECRET_MANAGEMENT.md
✅ Uploaded JAR_DOWNLOADS.md
✅ Uploaded secret management script

=== Deployment Complete - Next Steps ===

🎉 Deployment completed successfully!

Access Points:
1. 🌬️  Airflow UI: https://composer-ui-link
2. 📊 BigQuery Dataset: https://bigquery-dataset-link
3. 🗄️  Cloud SQL Connection: gcloud sql connect command

Secret Management:
4. 🔐 Manage database passwords:
   ./scripts/manage_secrets.sh -p my-project -e dev get-password
   ./scripts/manage_secrets.sh -p my-project -e dev rotate-password

Monitoring:
5. 📈 Monitor pipeline execution in Airflow
6. 🔍 Check secret access logs:
   gcloud logging read 'resource.type=secret_manager_secret' --project=my-project

Troubleshooting:
7. 🔧 Test database connection:
   python3 pyspark-jobs/database_utils.py
8. 📖 Read documentation: SECRET_MANAGEMENT.md

✅ All components deployed and ready for use!
```

#### Step 5: Validate Deployment (Optional)

Run the validation script to verify all components:

```bash
./scripts/validate_deployment.sh
```

This script validates:
- ✅ Terraform outputs
- ✅ GCS buckets and file structure
- ✅ Secret Manager configuration
- ✅ Cloud SQL instance status
- ✅ Dataproc cluster
- ✅ BigQuery dataset
- ✅ Cloud Composer environment

## 🔐 **Secret Management**

### Password Management Commands

The project includes comprehensive secret management tools:

```bash
# Get current password
./scripts/manage_secrets.sh -p YOUR_PROJECT_ID -e dev get-password

# Rotate password automatically
./scripts/manage_secrets.sh -p YOUR_PROJECT_ID -e dev rotate-password

# Update password manually
export TF_VAR_sql_user_password="NewPassword456!"
./scripts/manage_secrets.sh -p YOUR_PROJECT_ID -e dev update-password

# List all password versions
./scripts/manage_secrets.sh -p YOUR_PROJECT_ID -e dev list-versions

# View help for all options
./scripts/manage_secrets.sh --help
```

### Enhanced Database Connection

The new `database_utils.py` module provides:

- **Connection pooling** for efficient database connections
- **Automatic retry logic** for secret retrieval
- **Health checks** before establishing connections
- **Error handling** and comprehensive logging
- **JDBC optimization** for Spark workloads

```python
# Usage in PySpark jobs
from database_utils import create_database_manager_from_env

db_manager = create_database_manager_from_env()

# Health check
if db_manager.health_check():
    # Get optimized JDBC properties
    jdbc_props = db_manager.get_spark_jdbc_properties()
    jdbc_url = db_manager.get_jdbc_url()
    
    # Use in Spark DataFrame operations
    df = spark.read.jdbc(url=jdbc_url, table="products", properties=jdbc_props)
```

## 📊 **Post-Deployment**

### View Infrastructure Details
```bash
# View all outputs
terraform output

# View specific infrastructure summary
terraform output infrastructure_summary

# View next steps guidance
terraform output next_steps
```

### Access Services

**Cloud Composer (Airflow UI)**:
```bash
# Get Airflow URL
terraform output composer_airflow_uri
```

**BigQuery Console**:
```bash
# Get BigQuery dataset URL
terraform output bigquery_dataset_url
```

**Cloud SQL Connection**:
```bash
# Get connection command
terraform output connection_details
```

## 📁 **Data Upload Structure**

After deployment, upload your files from the project structure to GCS:

**Local Structure → GCS Structure:**
```
# Project files will be uploaded to:
gs://your-bucket-name/
├── sales_data/
│   └── sales_data.csv          # from sample_data/sales_data/
├── reference_data/
│   ├── products.csv            # from sample_data/reference_data/
│   └── stores.csv              # from sample_data/reference_data/
├── jars/
│   ├── spark-bigquery-with-dependencies_2.12-0.25.2.jar
│   └── postgresql-42.7.1.jar
└── pyspark-jobs/
    └── sales_analytics_direct.py

# Composer DAG bucket:
gs://composer-bucket/dags/
└── sales_etl_dag.py
```

**Upload Commands:**
```bash
# Get bucket names from Terraform output
terraform output upload_commands

# Or run manually:
export BUCKET_NAME=$(terraform output -raw data_bucket_name)
export COMPOSER_BUCKET=$(terraform output -raw composer_gcs_bucket)

# Upload all data files
gsutil -m cp -r sample_data/* gs://$BUCKET_NAME/

# Upload JAR files  
gsutil cp jars/*.jar gs://$BUCKET_NAME/jars/

# Upload PySpark job
gsutil cp pyspark-jobs/*.py gs://$BUCKET_NAME/pyspark-jobs/

# Upload Airflow DAG
gsutil cp dags/*.py gs://$COMPOSER_BUCKET/dags/
```

## 🔧 **Customization**

### Scaling Configuration
Edit `terraform.tfvars` to adjust:

**Dataproc Cluster**:
```hcl
dataproc_worker_nodes = 4           # Increase workers
dataproc_worker_machine_type = "e2-standard-4"  # Larger machines
```

**Cloud Composer**:
```hcl
composer_environment_size = "ENVIRONMENT_SIZE_MEDIUM"
composer_worker_max_count = 5
```

**Cloud SQL**:
```hcl
sql_tier = "db-n1-standard-1"       # Larger instance
sql_availability_type = "REGIONAL"   # High availability
```

### Cost Optimization
For demo/development:
```hcl
dataproc_preemptible_nodes = 2      # Add preemptible workers
sql_backup_enabled = false          # Disable backups
enable_force_destroy = true         # Enable cleanup
```

## 🧹 **Cleanup**

### Destroy All Infrastructure
```bash
terraform destroy
```

**Important**: This will delete all resources including data. Make sure to backup any important data before cleanup.

## 🔒 **Security Considerations**

### VPC Network Security
This infrastructure implements secure networking with:

- **Custom VPC**: Isolated network environment separate from default VPC
- **Private Subnets**: Data processing services (Dataproc, Cloud SQL) have no public IPs
- **Public Subnet**: Only Cloud Composer has internet access for workflow management
- **NAT Gateway**: Provides secure internet access for private subnet resources
- **Firewall Rules**: Restrictive rules allowing only necessary traffic
- **Private Google Access**: Enables private subnet access to Google APIs

### Subnet Architecture
- **Public Subnet** (`10.1.0.0/24`): Cloud Composer in `us-central1`
- **Private Subnet** (`10.2.0.0/24`): Dataproc, Cloud SQL in `asia-south1`
- **Secondary Ranges**: Dedicated IP ranges for Kubernetes pods and services

### Production Hardening
For production deployments, update:

1. **Network Security**:
   ```hcl
   # Already implemented: Cloud SQL in private subnet
   # Restrict SSH access in firewall rules
   source_ranges = ["YOUR_OFFICE_IP/32"]  # Replace 0.0.0.0/0
   ```

2. **Backup Configuration**:
   ```hcl
   sql_backup_enabled = true
   enable_force_destroy = false
   ```

3. **Service Account Keys**:
   - Use Workload Identity instead of service account keys
   - Implement least privilege access patterns

### Access Control
- ✅ **Service accounts** with minimal required permissions
- ✅ **Secret Manager** for secure password storage
- ✅ **IAM roles** properly assigned for each service
- ✅ **Private Google Access** enabled for API communication
- ✅ **Secrets encryption** at rest and in transit
- ✅ **No credentials in code** or environment variables

## 📈 **Monitoring**

### Infrastructure Monitoring
- **Cloud Composer**: Monitor via Airflow UI and Cloud Monitoring
- **Dataproc**: Check cluster health in GCP Console
- **Cloud SQL**: Monitor performance metrics
- **BigQuery**: Track query performance and costs

### Cost Monitoring
```bash
# Check current costs
gcloud billing budgets list

# Monitor resource usage
gcloud compute instances list
gcloud sql instances list
```

## 🛠️ **Troubleshooting**

### Common Issues

**1. Composer Deployment Fails**:
```bash
# Try different region
data_region = "us-central1"
orchestration_region = "us-east1"
```

**2. API Not Enabled**:
```bash
# Manually enable required APIs
gcloud services enable composer.googleapis.com
gcloud services enable dataproc.googleapis.com
```

**3. Quota Limits**:
- Check GCP quotas in Console
- Request quota increases if needed

**4. Service Account Permissions**:
```bash
# Verify service account has required roles
gcloud projects get-iam-policy YOUR_PROJECT_ID
```

## 📚 **Architecture Overview**

```
┌─────────────────────────────────────────────────────────────────┐
│                    ETL Infrastructure                           │
├─────────────────────────────────────────────────────────────────┤
│                      Custom VPC Network                        │
│  ┌─────────────────────────┬─────────────────────────────────┐  │
│  │     Public Subnet       │        Private Subnet           │  │
│  │    (us-central1)        │       (asia-south1)             │  │
│  │                         │                                 │  │
│  │  ┌─────────────────┐    │    ┌─────────────────────────┐  │  │
│  │  │ Cloud Composer  │◄───┼────┤     Dataproc Cluster   │  │  │
│  │  │   (Airflow)     │    │    │   (Spark Processing)    │  │  │
│  │  └─────────────────┘    │    └─────────────────────────┘  │  │
│  │          │               │              │                 │  │
│  │          ▼               │              ▼                 │  │
│  │  ┌─────────────────┐    │    ┌─────────────────────────┐  │  │
│  │  │   Internet      │    │    │      Cloud SQL          │  │  │
│  │  │   Gateway       │    │    │    (PostgreSQL)         │  │  │
│  │  └─────────────────┘    │    └─────────────────────────┘  │  │
│  └─────────────────────────┼─────────────────────────────────┘  │
│                             │                   │               │
│                             │    ┌─────────────▼─────────────┐  │
│                             │    │        NAT Gateway        │  │
│                             │    │   (Internet Access)       │  │
│                             │    └───────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                   Global Services                          │  │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │  │
│  │  │     GCS     │    │  BigQuery   │    │    IAM      │    │  │
│  │  │ Data Lake   │    │ Analytics   │    │  Security   │    │  │
│  │  └─────────────┘    └─────────────┘    └─────────────┘    │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## 🎯 **Next Steps**

1. **Deploy Infrastructure**: Run `terraform apply`
2. **Upload Data**: Copy your CSV files to GCS buckets
3. **Create DAG**: Upload Airflow DAG to Composer
4. **Run Pipeline**: Trigger workflow via Airflow UI
5. **Analyze Results**: Query BigQuery analytics tables

For detailed step-by-step instructions, see the implementation guides in the parent directories.

---

**Happy ETL Pipeline Building! 🚀** 