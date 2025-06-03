output "sql_password_secret_id" {
  description = "Secret Manager secret ID for SQL password"
  value       = google_secret_manager_secret.sql_password.secret_id
}

output "sql_password_secret_name" {
  description = "Full secret name for accessing SQL password"
  value       = google_secret_manager_secret.sql_password.name
} 