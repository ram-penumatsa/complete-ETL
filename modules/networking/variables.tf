# ===================================================================
# NETWORKING MODULE VARIABLES
# ===================================================================

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

# Network CIDR Configuration
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