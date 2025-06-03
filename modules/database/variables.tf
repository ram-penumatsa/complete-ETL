# ===================================================================
# DATABASE MODULE VARIABLES
# ===================================================================

variable "sql_instance_name" {
  description = "Cloud SQL PostgreSQL instance name"
  type        = string
}

variable "data_region" {
  description = "Region for data processing resources"
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

variable "vpc_id" {
  description = "VPC ID for private networking"
  type        = string
}

variable "private_vpc_connection" {
  description = "Private VPC connection for Cloud SQL"
  type        = any
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
} 