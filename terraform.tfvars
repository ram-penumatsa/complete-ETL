# ===================================================================
# MODULAR ETL INFRASTRUCTURE - TERRAFORM VARIABLES
# ===================================================================

# ===================================================================
# CORE CONFIGURATION
# ===================================================================

# Your GCP Project ID
project_id = "strong-market-461106-p0"

# Default region for provider
default_region = "us-central1"

# Environment type
environment = "dev"

# Enable force destroy for demo cleanup (set to false for production)
enable_force_destroy = true

# ===================================================================
# REGIONAL CONFIGURATION
# ===================================================================

# Data processing region (Dataproc, Cloud SQL, GCS)
data_region = "asia-south1"

# Cloud Composer orchestration region
orchestration_region = "us-central1"

# BigQuery location
bigquery_location = "asia-south1"

# ===================================================================
# NETWORK CONFIGURATION
# ===================================================================

# VPC subnet CIDR ranges
public_subnet_cidr  = "10.1.0.0/24"    # Cloud Composer
private_subnet_cidr = "10.2.0.0/24"    # Dataproc, Cloud SQL

# Secondary IP ranges for services
composer_pods_cidr     = "10.10.0.0/16"  # Composer pods
composer_services_cidr = "10.11.0.0/16"  # Composer services
dataproc_pods_cidr     = "10.12.0.0/16"  # Dataproc secondary IPs

# ===================================================================
# STORAGE CONFIGURATION
# ===================================================================

# GCS bucket name (must be globally unique - update with your project)
data_bucket_name = "pram-final-etl-data-lake"

# ===================================================================
# DATABASE CONFIGURATION
# ===================================================================

# Cloud SQL PostgreSQL instance configuration
sql_instance_name     = "etl-postgres"
sql_database_name     = "retail_sql"
sql_user_name         = "retail_user"
sql_user_password     = "YourSecurePassword123!"  # Use environment variable in production: TF_VAR_sql_user_password

# Cloud SQL instance sizing (cost-optimized for demo)
sql_tier              = "db-f1-micro"
sql_availability_type = "ZONAL"
sql_disk_size         = 20
sql_backup_enabled    = false # Disabled for cost savings

# ===================================================================
# COMPUTE CONFIGURATION (DATAPROC)
# ===================================================================

# Dataproc cluster configuration
dataproc_cluster_name = "pram-final-etl-dataproc-cluster"

# Master node configuration
dataproc_master_nodes        = 1
dataproc_master_machine_type = "e2-standard-2"
dataproc_master_disk_size    = 50

# Worker node configuration
dataproc_worker_nodes        = 2
dataproc_worker_machine_type = "e2-standard-2"
dataproc_worker_disk_size    = 32

# Preemptible workers for cost optimization
dataproc_preemptible_nodes = 0

# Dataproc image version
dataproc_image_version = "2.1-debian11"

# ===================================================================
# ANALYTICS CONFIGURATION (BIGQUERY)
# ===================================================================

# BigQuery dataset for analytics results
bigquery_dataset_id = "pram_final_sales_analytics"

# ===================================================================
# ORCHESTRATION CONFIGURATION (CLOUD COMPOSER)
# ===================================================================

# Cloud Composer environment configuration
composer_name = "pram-final-etl-composer"

# Composer image version
composer_image_version = "composer-2.5.4-airflow-2.7.3"

# Composer sizing (cost-optimized for demo)
composer_environment_size = "SMALL"

# Composer workload resource allocation (small for demo)
composer_scheduler_cpu     = 0.5
composer_scheduler_memory  = 1.875
composer_scheduler_storage = 1

composer_webserver_cpu     = 0.5
composer_webserver_memory  = 1.875
composer_webserver_storage = 1

composer_worker_cpu        = 0.5
composer_worker_memory     = 1.875
composer_worker_storage    = 1
composer_worker_min_count  = 1
composer_worker_max_count  = 3 