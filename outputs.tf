# ===================================================================
# MODULAR INFRASTRUCTURE OUTPUTS
# ===================================================================

# Project Information
output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

# ===================================================================
# STORAGE OUTPUTS (from storage module)
# ===================================================================

output "data_bucket_name" {
  description = "Name of the main data bucket"
  value       = module.storage.data_bucket_name
}

output "data_bucket_url" {
  description = "URL of the main data bucket"
  value       = module.storage.data_bucket_url
}

output "staging_bucket_name" {
  description = "Name of the staging bucket"
  value       = module.storage.staging_bucket_name
}

output "staging_bucket_url" {
  description = "URL of the staging bucket"
  value       = module.storage.staging_bucket_url
}

# ===================================================================
# DATABASE OUTPUTS (from database module)
# ===================================================================

output "sql_instance_name" {
  description = "Cloud SQL instance name"
  value       = module.database.sql_instance_name
}

output "sql_connection_name" {
  description = "Cloud SQL connection name"
  value       = module.database.sql_connection_name
}

output "sql_private_ip" {
  description = "Cloud SQL private IP address"
  value       = module.database.sql_private_ip
}

output "sql_database_name" {
  description = "PostgreSQL database name"
  value       = module.database.sql_database_name
}

output "sql_user_name" {
  description = "PostgreSQL user name"
  value       = module.database.sql_user_name
  sensitive   = true
}

# ===================================================================
# COMPUTE OUTPUTS (from compute module)
# ===================================================================

output "dataproc_cluster_name" {
  description = "Dataproc cluster name"
  value       = module.compute.dataproc_cluster_name
}

output "dataproc_cluster_region" {
  description = "Dataproc cluster region"
  value       = module.compute.dataproc_cluster_region
}

output "dataproc_master_instance_names" {
  description = "Dataproc master instance names"
  value       = module.compute.dataproc_master_instance_names
}

output "dataproc_worker_instance_names" {
  description = "Dataproc worker instance names"
  value       = module.compute.dataproc_worker_instance_names
}

# ===================================================================
# ANALYTICS OUTPUTS (from analytics module)
# ===================================================================

output "bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  value       = module.analytics.bigquery_dataset_id
}

output "bigquery_dataset_location" {
  description = "BigQuery dataset location"
  value       = module.analytics.bigquery_dataset_location
}

output "bigquery_dataset_url" {
  description = "BigQuery dataset URL"
  value       = module.analytics.bigquery_dataset_url
}

# ===================================================================
# ORCHESTRATION OUTPUTS (from orchestration module)
# ===================================================================

output "composer_environment_name" {
  description = "Cloud Composer environment name"
  value       = module.orchestration.composer_environment_name
}

output "composer_airflow_uri" {
  description = "Airflow web UI URL"
  value       = module.orchestration.composer_environment_uri
}

output "composer_gcs_bucket" {
  description = "Composer GCS bucket for DAGs"
  value       = module.orchestration.composer_gcs_bucket
}

# ===================================================================
# SERVICE ACCOUNT OUTPUTS (from iam module)
# ===================================================================

output "composer_service_account_email" {
  description = "Cloud Composer service account email"
  value       = module.iam.composer_service_account_email
}

output "dataproc_service_account_email" {
  description = "Dataproc service account email"
  value       = module.iam.dataproc_service_account_email
}

# ===================================================================
# SECRET MANAGER OUTPUTS (from security module)
# ===================================================================

output "sql_password_secret_id" {
  description = "Secret Manager secret ID for SQL password"
  value       = module.security.sql_password_secret_id
}

output "sql_password_secret_name" {
  description = "Full secret name for accessing SQL password"
  value       = module.security.sql_password_secret_name
}

# ===================================================================
# NETWORK OUTPUTS (from networking module)
# ===================================================================

output "vpc_name" {
  description = "Name of the custom VPC"
  value       = module.networking.vpc_name
}

output "vpc_id" {
  description = "ID of the custom VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_name" {
  description = "Name of the public subnet (Cloud Composer)"
  value       = module.networking.public_subnet_name
}

output "public_subnet_cidr" {
  description = "CIDR range of the public subnet"
  value       = module.networking.public_subnet_cidr
}

output "private_subnet_name" {
  description = "Name of the private subnet (Dataproc, Cloud SQL)"
  value       = module.networking.private_subnet_name
}

output "private_subnet_cidr" {
  description = "CIDR range of the private subnet"
  value       = module.networking.private_subnet_cidr
}

output "nat_gateway_name" {
  description = "Name of the NAT gateway for private subnet"
  value       = module.networking.nat_gateway_name
}

# ===================================================================
# DEPLOYMENT SUMMARY
# ===================================================================

output "infrastructure_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    # Project info
    project_id  = var.project_id
    environment = var.environment

    # Regional distribution
    data_region          = var.data_region
    orchestration_region = var.orchestration_region
    bigquery_location    = var.bigquery_location

    # Network infrastructure
    vpc_name       = module.networking.vpc_name
    public_subnet  = module.networking.public_subnet_name
    private_subnet = module.networking.private_subnet_name
    nat_gateway    = module.networking.nat_gateway_name

    # Storage
    data_bucket    = module.storage.data_bucket_name
    staging_bucket = module.storage.staging_bucket_name

    # Database
    sql_instance   = module.database.sql_instance_name
    sql_private_ip = module.database.sql_private_ip
    sql_database   = module.database.sql_database_name

    # Secret Management
    sql_password_secret = module.security.sql_password_secret_id

    # Compute
    dataproc_cluster = module.compute.dataproc_cluster_name

    # Analytics
    bigquery_dataset = module.analytics.bigquery_dataset_id

    # Orchestration
    composer_environment = module.orchestration.composer_environment_name
    airflow_ui_url       = module.orchestration.composer_environment_uri
  }
}

# ===================================================================
# NEXT STEPS GUIDANCE
# ===================================================================

output "next_steps" {
  description = "Next steps for using the deployed infrastructure"
  value = {
    "1_upload_sample_data" = "Upload sample CSV files: gsutil -m cp -r sample_data/* gs://${module.storage.data_bucket_name}/"
    "2_upload_jars"        = "Upload JAR files: gsutil cp jars/*.jar gs://${module.storage.data_bucket_name}/jars/"
    "3_upload_pyspark"     = "Upload PySpark job: gsutil cp pyspark-jobs/*.py gs://${module.storage.data_bucket_name}/pyspark-jobs/"
    "4_upload_dag"         = "Upload Airflow DAG: gsutil cp dags/*.py gs://${module.orchestration.composer_gcs_bucket}dags/"
    "5_access_airflow"     = "Access Airflow UI at: ${module.orchestration.composer_environment_uri}"
    "6_monitor_bigquery"   = "View results in BigQuery dataset: ${var.project_id}.${module.analytics.bigquery_dataset_id}"
  }
}

# ===================================================================
# CONNECTION INFORMATION
# ===================================================================

output "connection_details" {
  description = "Connection details for accessing services"
  value = {
    # Cloud SQL connection
    sql_connection_command = "gcloud sql connect ${module.database.sql_instance_name} --user=${module.database.sql_user_name} --database=${module.database.sql_database_name}"
    sql_jdbc_url           = "jdbc:postgresql://${module.database.sql_private_ip}:5432/${module.database.sql_database_name}"

    # Dataproc commands
    dataproc_ssh_command = "gcloud compute ssh ${module.compute.dataproc_master_instance_names[0]} --zone=${var.data_region}-a"
    dataproc_job_submit  = "gcloud dataproc jobs submit pyspark --cluster=${module.compute.dataproc_cluster_name} --region=${var.data_region}"

    # BigQuery access
    bigquery_query_command = "bq query --use_legacy_sql=false"
    bigquery_dataset_url   = module.analytics.bigquery_dataset_url

    # Network information
    vpc_name            = module.networking.vpc_name
    public_subnet_cidr  = module.networking.public_subnet_cidr
    private_subnet_cidr = module.networking.private_subnet_cidr
  }
  sensitive = true
}

# ===================================================================
# UPLOAD COMMANDS
# ===================================================================

output "upload_commands" {
  description = "Complete upload commands for all project files"
  value = {
    setup_commands = [
      "# Set environment variables",
      "export BUCKET_NAME=${module.storage.data_bucket_name}",
      "export COMPOSER_BUCKET=${module.orchestration.composer_gcs_bucket}",
      "",
      "# Upload data files",
      "gsutil -m cp -r sample_data/* gs://$BUCKET_NAME/",
      "",
      "# Upload JAR dependencies",
      "gsutil cp jars/*.jar gs://$BUCKET_NAME/jars/",
      "",
      "# Upload PySpark job",
      "gsutil cp pyspark-jobs/*.py gs://$BUCKET_NAME/pyspark-jobs/",
      "",
      "# Upload Airflow DAG",
      "gsutil cp dags/*.py gs://$COMPOSER_BUCKET/dags/",
      "",
      "# Verify uploads",
      "gsutil ls -r gs://$BUCKET_NAME",
      "gsutil ls gs://$COMPOSER_BUCKET/dags/"
    ]
  }
} 