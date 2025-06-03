# ===================================================================
# COMPUTE MODULE OUTPUTS
# ===================================================================

output "dataproc_cluster_name" {
  description = "Dataproc cluster name"
  value       = google_dataproc_cluster.etl_cluster.name
}

output "dataproc_cluster_region" {
  description = "Dataproc cluster region"
  value       = google_dataproc_cluster.etl_cluster.region
}

output "dataproc_master_instance_names" {
  description = "Dataproc master instance names"
  value       = google_dataproc_cluster.etl_cluster.cluster_config[0].master_config[0].instance_names
}

output "dataproc_worker_instance_names" {
  description = "Dataproc worker instance names"
  value       = google_dataproc_cluster.etl_cluster.cluster_config[0].worker_config[0].instance_names
} 