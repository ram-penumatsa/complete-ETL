# ===================================================================
# ORCHESTRATION MODULE VARIABLES
# ===================================================================

variable "composer_name" {
  description = "Cloud Composer environment name"
  type        = string
}

variable "orchestration_region" {
  description = "Region for Cloud Composer deployment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Composer networking"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for Composer"
  type        = string
}

variable "composer_service_account_email" {
  description = "Composer service account email"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "composer_image_version" {
  description = "Cloud Composer image version"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "data_region" {
  description = "Data processing region"
  type        = string
}

variable "dataproc_cluster_name" {
  description = "Dataproc cluster name"
  type        = string
}

variable "data_bucket_name" {
  description = "Data bucket name"
  type        = string
}

variable "sql_connection_name" {
  description = "Cloud SQL connection name"
  type        = string
}

variable "sql_private_ip" {
  description = "Cloud SQL private IP address"
  type        = string
}

variable "sql_database_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "sql_user_name" {
  description = "PostgreSQL user name"
  type        = string
}

variable "sql_password_secret_id" {
  description = "Secret Manager secret ID for SQL password"
  type        = string
}

variable "bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
}

# Composer Workload Configuration
variable "composer_scheduler_cpu" {
  description = "CPU for Composer scheduler"
  type        = number
}

variable "composer_scheduler_memory" {
  description = "Memory for Composer scheduler (GB)"
  type        = number
}

variable "composer_scheduler_storage" {
  description = "Storage for Composer scheduler (GB)"
  type        = number
}

variable "composer_webserver_cpu" {
  description = "CPU for Composer web server"
  type        = number
}

variable "composer_webserver_memory" {
  description = "Memory for Composer web server (GB)"
  type        = number
}

variable "composer_webserver_storage" {
  description = "Storage for Composer web server (GB)"
  type        = number
}

variable "composer_worker_cpu" {
  description = "CPU for Composer workers"
  type        = number
}

variable "composer_worker_memory" {
  description = "Memory for Composer workers (GB)"
  type        = number
}

variable "composer_worker_storage" {
  description = "Storage for Composer workers (GB)"
  type        = number
}

variable "composer_worker_min_count" {
  description = "Minimum worker count"
  type        = number
}

variable "composer_worker_max_count" {
  description = "Maximum worker count"
  type        = number
}

variable "composer_environment_size" {
  description = "Composer environment size (SMALL, MEDIUM, LARGE)"
  type        = string
} 