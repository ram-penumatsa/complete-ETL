output "data_bucket_name" {
  description = "Name of the main data bucket"
  value       = google_storage_bucket.data_bucket.name
}

output "data_bucket_url" {
  description = "URL of the main data bucket"
  value       = google_storage_bucket.data_bucket.url
}

output "staging_bucket_name" {
  description = "Name of the staging bucket"
  value       = google_storage_bucket.staging_bucket.name
}

output "staging_bucket_url" {
  description = "URL of the staging bucket"
  value       = google_storage_bucket.staging_bucket.url
} 