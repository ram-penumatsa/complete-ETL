# ===================================================================
# COMPUTE MODULE VARIABLES
# ===================================================================

variable "dataproc_cluster_name" {
  description = "Name for the Dataproc cluster"
  type        = string
}

variable "data_region" {
  description = "Region for data processing resources"
  type        = string
}

variable "staging_bucket_name" {
  description = "Name of the staging bucket for Dataproc"
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

variable "private_subnet_name" {
  description = "Name of the private subnet for Dataproc"
  type        = string
}

variable "dataproc_service_account_email" {
  description = "Dataproc service account email"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
} 