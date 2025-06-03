# ===================================================================
# PROJECT CONFIGURATION
# ===================================================================

variable "project_id" {
  description = "GCP Project ID for infrastructure deployment"
  type        = string
}

variable "default_region" {
  description = "Default GCP region for infrastructure"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "enable_force_destroy" {
  description = "Enable force destroy for demo cleanup (set to false for production)"
  type        = bool
  default     = true
}

# ===================================================================
# REGIONAL CONFIGURATION
# ===================================================================

variable "data_region" {
  description = "Region for data processing resources (Dataproc, Cloud SQL, GCS)"
  type        = string
  default     = "asia-south1"
}

variable "orchestration_region" {
  description = "Region for Cloud Composer deployment"
  type        = string
  default     = "us-central1"
}

variable "bigquery_location" {
  description = "Location for BigQuery datasets"
  type        = string
  default     = "asia-south1"
}

# ===================================================================
# NETWORK CONFIGURATION (VPC)
# ===================================================================

variable "public_subnet_cidr" {
  description = "CIDR range for public subnet (Cloud Composer)"
  type        = string
  default     = "10.1.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR range for private subnet (Dataproc, Cloud SQL)"
  type        = string
  default     = "10.2.0.0/24"
}

variable "composer_pods_cidr" {
  description = "CIDR range for Cloud Composer pods secondary IP range"
  type        = string
  default     = "10.3.0.0/16"
}

variable "composer_services_cidr" {
  description = "CIDR range for Cloud Composer services secondary IP range"
  type        = string
  default     = "10.4.0.0/16"
}

variable "dataproc_pods_cidr" {
  description = "CIDR range for Dataproc secondary IP range"
  type        = string
  default     = "10.5.0.0/16"
}

# ===================================================================
# STORAGE CONFIGURATION (GCS)
# ===================================================================

variable "data_bucket_name" {
  description = "Name for the main data storage bucket (must be globally unique)"
  type        = string
}

# ===================================================================
# DATABASE CONFIGURATION (CLOUD SQL)
# ===================================================================

variable "sql_instance_name" {
  description = "Cloud SQL PostgreSQL instance name"
  type        = string
  default     = "etl-postgres"
}

variable "sql_database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "retail_sql"
}

variable "sql_user_name" {
  description = "PostgreSQL user name"
  type        = string
  default     = "retail_user"
}

variable "sql_user_password" {
  description = "PostgreSQL user password"
  type        = string
  sensitive   = true
}

variable "sql_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "sql_availability_type" {
  description = "Cloud SQL availability type (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"
}

variable "sql_disk_size" {
  description = "Cloud SQL disk size in GB"
  type        = number
  default     = 20
}

variable "sql_backup_enabled" {
  description = "Enable Cloud SQL backups (disable for cost savings in demo)"
  type        = bool
  default     = false
}

# ===================================================================
# COMPUTE CONFIGURATION (DATAPROC)
# ===================================================================

variable "dataproc_cluster_name" {
  description = "Name for the Dataproc cluster"
  type        = string
  default     = "pram-final-etl-dataproc-cluster"
}

variable "dataproc_image_version" {
  description = "Dataproc image version"
  type        = string
  default     = "2.1-debian11"
}

# Master node configuration
variable "dataproc_master_nodes" {
  description = "Number of master nodes in Dataproc cluster"
  type        = number
  default     = 1
}

variable "dataproc_master_machine_type" {
  description = "Machine type for Dataproc master nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "dataproc_master_disk_size" {
  description = "Boot disk size for Dataproc master nodes (GB)"
  type        = number
  default     = 50
}

# Worker node configuration
variable "dataproc_worker_nodes" {
  description = "Number of worker nodes in Dataproc cluster"
  type        = number
  default     = 2
}

variable "dataproc_worker_machine_type" {
  description = "Machine type for Dataproc worker nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "dataproc_worker_disk_size" {
  description = "Boot disk size for Dataproc worker nodes (GB)"
  type        = number
  default     = 32
}

# Preemptible worker configuration
variable "dataproc_preemptible_nodes" {
  description = "Number of preemptible worker nodes (cost optimization)"
  type        = number
  default     = 0
}

# ===================================================================
# ANALYTICS CONFIGURATION (BIGQUERY)
# ===================================================================

variable "bigquery_dataset_id" {
  description = "BigQuery dataset ID for analytics results"
  type        = string
  default     = "pram_final_sales_analytics"
}

# ===================================================================
# ORCHESTRATION CONFIGURATION (CLOUD COMPOSER)
# ===================================================================

variable "composer_name" {
  description = "Cloud Composer environment name"
  type        = string
  default     = "pram-final-etl-composer"
}

variable "composer_image_version" {
  description = "Cloud Composer image version"
  type        = string
  default     = "composer-2-airflow-2"
}

variable "composer_machine_type" {
  description = "Machine type for Composer nodes"
  type        = string
  default     = "n1-standard-1"
}

variable "composer_environment_size" {
  description = "Composer environment size (ENVIRONMENT_SIZE_SMALL/MEDIUM/LARGE)"
  type        = string
  default     = "ENVIRONMENT_SIZE_SMALL"
}

# Scheduler configuration
variable "composer_scheduler_cpu" {
  description = "CPU allocation for Composer scheduler"
  type        = number
  default     = 0.5
}

variable "composer_scheduler_memory" {
  description = "Memory allocation for Composer scheduler (GB)"
  type        = number
  default     = 1.875
}

variable "composer_scheduler_storage" {
  description = "Storage allocation for Composer scheduler (GB)"
  type        = number
  default     = 1
}

# Web server configuration
variable "composer_webserver_cpu" {
  description = "CPU allocation for Composer web server"
  type        = number
  default     = 0.5
}

variable "composer_webserver_memory" {
  description = "Memory allocation for Composer web server (GB)"
  type        = number
  default     = 1.875
}

variable "composer_webserver_storage" {
  description = "Storage allocation for Composer web server (GB)"
  type        = number
  default     = 1
}

# Worker configuration
variable "composer_worker_cpu" {
  description = "CPU allocation for Composer workers"
  type        = number
  default     = 0.5
}

variable "composer_worker_memory" {
  description = "Memory allocation for Composer workers (GB)"
  type        = number
  default     = 1.875
}

variable "composer_worker_storage" {
  description = "Storage allocation for Composer workers (GB)"
  type        = number
  default     = 1
}

variable "composer_worker_min_count" {
  description = "Minimum number of Composer workers"
  type        = number
  default     = 1
}

variable "composer_worker_max_count" {
  description = "Maximum number of Composer workers"
  type        = number
  default     = 3
} 