variable "data_bucket_name" {
  description = "Name for the main data storage bucket"
  type        = string
}

variable "data_region" {
  description = "Region for data processing resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_force_destroy" {
  description = "Enable force destroy for demo cleanup"
  type        = bool
  default     = true
} 