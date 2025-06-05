# ===================================================================
# MODULAR ETL INFRASTRUCTURE - VARIABLES
# ===================================================================

# Core Configuration
variable "project_id" {
  description = "GCP Project ID for infrastructure deployment"
  type        = string
}

variable "default_region" {
  description = "Default GCP region for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "orchestration_region" {
  description = "Region for Cloud Composer deployment"
  type        = string
}

variable "data_region" {
  description = "Region for data processing resources (Dataproc, Cloud SQL, GCS)"
  type        = string
}

# Network Configuration
variable "public_subnet_cidr" {
  description = "CIDR range for public subnet (Cloud Composer)"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR range for private subnet (Dataproc, Cloud SQL)"
  type        = string
}

variable "composer_pods_cidr" {
  description = "CIDR range for Cloud Composer pods secondary IP range"
  type        = string
}

variable "composer_services_cidr" {
  description = "CIDR range for Cloud Composer services secondary IP range"
  type        = string
}

variable "dataproc_pods_cidr" {
  description = "CIDR range for Dataproc secondary IP range"
  type        = string
}

# Storage Configuration
variable "data_bucket_name" {
  description = "Name for the main data storage bucket"
  type        = string
}

variable "enable_force_destroy" {
  description = "Enable force destroy for demo cleanup"
  type        = bool
  default     = true
}

# Database Configuration
variable "sql_instance_name" {
  description = "Cloud SQL PostgreSQL instance name"
  type        = string
}

variable "sql_tier" {
  description = "Cloud SQL instance tier"
  type        = string
}

variable "sql_availability_type" {
  description = "Cloud SQL availability type (ZONAL or REGIONAL)"
  type        = string
}

variable "sql_disk_size" {
  description = "Cloud SQL disk size in GB"
  type        = number
}

variable "sql_backup_enabled" {
  description = "Enable Cloud SQL backups"
  type        = bool
}

variable "sql_database_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "sql_user_name" {
  description = "PostgreSQL user name"
  type        = string
}

variable "sql_user_password" {
  description = "PostgreSQL user password"
  type        = string
  sensitive   = true
  default     = ""  # Empty default - allows destroy without prompts
}

# Dataproc Configuration
variable "dataproc_cluster_name" {
  description = "Name for the Dataproc cluster"
  type        = string
}

variable "dataproc_master_nodes" {
  description = "Number of master nodes in Dataproc cluster"
  type        = number
}

variable "dataproc_master_machine_type" {
  description = "Machine type for Dataproc master nodes"
  type        = string
}

variable "dataproc_master_disk_size" {
  description = "Boot disk size for Dataproc master nodes (GB)"
  type        = number
}

variable "dataproc_worker_nodes" {
  description = "Number of worker nodes in Dataproc cluster"
  type        = number
}

variable "dataproc_worker_machine_type" {
  description = "Machine type for Dataproc worker nodes"
  type        = string
}

variable "dataproc_worker_disk_size" {
  description = "Boot disk size for Dataproc worker nodes (GB)"
  type        = number
}

variable "dataproc_preemptible_nodes" {
  description = "Number of preemptible worker nodes"
  type        = number
}

variable "dataproc_image_version" {
  description = "Dataproc image version"
  type        = string
}

# BigQuery Configuration
variable "bigquery_dataset_id" {
  description = "BigQuery dataset ID for analytics"
  type        = string
}

variable "bigquery_location" {
  description = "BigQuery dataset location"
  type        = string
}

# Cloud Composer Configuration
variable "composer_name" {
  description = "Cloud Composer environment name"
  type        = string
}

variable "composer_image_version" {
  description = "Cloud Composer image version"
  type        = string
}

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