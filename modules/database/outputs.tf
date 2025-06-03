# ===================================================================
# DATABASE MODULE OUTPUTS
# ===================================================================

output "sql_instance_name" {
  description = "Cloud SQL instance name"
  value       = google_sql_database_instance.postgres.name
}

output "sql_connection_name" {
  description = "Cloud SQL connection name"
  value       = google_sql_database_instance.postgres.connection_name
}

output "sql_private_ip" {
  description = "Cloud SQL private IP address"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "sql_database_name" {
  description = "PostgreSQL database name"
  value       = google_sql_database.etl_database.name
}

output "sql_user_name" {
  description = "PostgreSQL user name"
  value       = google_sql_user.etl_user.name
  sensitive   = true
} 