# ===================================================================
# FOUNDATION MODULE OUTPUTS
# ===================================================================

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "enabled_apis" {
  description = "List of enabled APIs"
  value       = [for api in google_project_service.required_apis : api.service]
}

output "foundation_complete" {
  description = "Indicates that foundation setup is complete"
  value       = true
  depends_on  = [google_project_service.required_apis]
} 