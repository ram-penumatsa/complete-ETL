# ===================================================================
# INFRASTRUCTURE OUTPUTS
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
# STORAGE OUTPUTS (GCS)
# ===================================================================

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

# ===================================================================
# DATABASE OUTPUTS (CLOUD SQL)
# ===================================================================

output "sql_instance_name" {
  description = "Cloud SQL instance name"
  value       = google_sql_database_instance.postgres.name
}

output "sql_connection_name" {
  description = "Cloud SQL connection name"
  value       = google_sql_database_instance.postgres.connection_name
}

output "sql_public_ip" {
  description = "Cloud SQL public IP address"
  value       = google_sql_database_instance.postgres.public_ip_address
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

# ===================================================================
# COMPUTE OUTPUTS (DATAPROC)
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

# ===================================================================
# ANALYTICS OUTPUTS (BIGQUERY)
# ===================================================================

output "bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  value       = google_bigquery_dataset.sales_analytics.dataset_id
}

output "bigquery_dataset_location" {
  description = "BigQuery dataset location"
  value       = google_bigquery_dataset.sales_analytics.location
}

output "bigquery_dataset_url" {
  description = "BigQuery dataset URL"
  value       = "https://console.cloud.google.com/bigquery?project=${var.project_id}&p=${var.project_id}&d=${google_bigquery_dataset.sales_analytics.dataset_id}&page=dataset"
}

# ===================================================================
# ORCHESTRATION OUTPUTS (CLOUD COMPOSER)
# ===================================================================

output "composer_environment_name" {
  description = "Cloud Composer environment name"
  value       = google_composer_environment.etl_composer.name
}

output "composer_region" {
  description = "Cloud Composer region"
  value       = google_composer_environment.etl_composer.region
}

output "composer_airflow_uri" {
  description = "Airflow web UI URL"
  value       = google_composer_environment.etl_composer.config[0].airflow_uri
}

output "composer_gcs_bucket" {
  description = "Composer GCS bucket for DAGs"
  value       = google_composer_environment.etl_composer.config[0].dag_gcs_prefix
}

output "composer_node_count" {
  description = "Composer node count"
  value       = google_composer_environment.etl_composer.config[0].node_count
}

# ===================================================================
# SERVICE ACCOUNT OUTPUTS
# ===================================================================

output "composer_service_account_email" {
  description = "Cloud Composer service account email"
  value       = data.google_service_account.composer_sa.email
}

output "dataproc_service_account_email" {
  description = "Dataproc service account email"
  value       = data.google_service_account.dataproc_sa.email
}

# ===================================================================
# SECRET MANAGER OUTPUTS
# ===================================================================

output "sql_password_secret_id" {
  description = "Secret Manager secret ID for SQL password"
  value       = google_secret_manager_secret.sql_password.secret_id
}

output "sql_password_secret_name" {
  description = "Full secret name for accessing SQL password"
  value       = google_secret_manager_secret.sql_password.name
}

# ===================================================================
# NETWORK OUTPUTS (VPC)
# ===================================================================

output "vpc_name" {
  description = "Name of the custom VPC"
  value       = google_compute_network.etl_vpc.name
}

output "vpc_id" {
  description = "ID of the custom VPC"
  value       = google_compute_network.etl_vpc.id
}

output "public_subnet_name" {
  description = "Name of the public subnet (Cloud Composer)"
  value       = google_compute_subnetwork.public_subnet.name
}

output "public_subnet_cidr" {
  description = "CIDR range of the public subnet"
  value       = google_compute_subnetwork.public_subnet.ip_cidr_range
}

output "private_subnet_name" {
  description = "Name of the private subnet (Dataproc, Cloud SQL)"
  value       = google_compute_subnetwork.private_subnet.name
}

output "private_subnet_cidr" {
  description = "CIDR range of the private subnet"
  value       = google_compute_subnetwork.private_subnet.ip_cidr_range
}

output "nat_gateway_name" {
  description = "Name of the NAT gateway for private subnet"
  value       = google_compute_router_nat.nat_gateway.name
}

output "sql_private_ip" {
  description = "Cloud SQL private IP address"
  value       = google_sql_database_instance.postgres.private_ip_address
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
    vpc_name       = google_compute_network.etl_vpc.name
    public_subnet  = google_compute_subnetwork.public_subnet.name
    private_subnet = google_compute_subnetwork.private_subnet.name
    nat_gateway    = google_compute_router_nat.nat_gateway.name

    # Storage
    data_bucket    = google_storage_bucket.data_bucket.name
    staging_bucket = google_storage_bucket.staging_bucket.name

    # Database
    sql_instance   = google_sql_database_instance.postgres.name
    sql_private_ip = google_sql_database_instance.postgres.private_ip_address
    sql_database   = google_sql_database.etl_database.name

    # Secret Management
    sql_password_secret = google_secret_manager_secret.sql_password.secret_id

    # Compute
    dataproc_cluster = google_dataproc_cluster.etl_cluster.name

    # Analytics
    bigquery_dataset = google_bigquery_dataset.sales_analytics.dataset_id

    # Orchestration
    composer_environment = google_composer_environment.etl_composer.name
    airflow_ui_url       = google_composer_environment.etl_composer.config[0].airflow_uri
  }
}

# ===================================================================
# NEXT STEPS GUIDANCE
# ===================================================================

output "next_steps" {
  description = "Next steps for using the deployed infrastructure"
  value = {
    "1_upload_sample_data" = "Upload sample CSV files: gsutil -m cp -r sample_data/* gs://${google_storage_bucket.data_bucket.name}/"
    "2_upload_jars"        = "Upload JAR files: gsutil cp jars/*.jar gs://${google_storage_bucket.data_bucket.name}/jars/"
    "3_upload_pyspark"     = "Upload PySpark job: gsutil cp pyspark-jobs/*.py gs://${google_storage_bucket.data_bucket.name}/pyspark-jobs/"
    "4_upload_dag"         = "Upload Airflow DAG: gsutil cp dags/*.py gs://${google_composer_environment.etl_composer.config[0].dag_gcs_prefix}dags/"
    "5_access_airflow"     = "Access Airflow UI at: ${google_composer_environment.etl_composer.config[0].airflow_uri}"
    "6_monitor_bigquery"   = "View results in BigQuery dataset: ${var.project_id}.${google_bigquery_dataset.sales_analytics.dataset_id}"
  }
}

# ===================================================================
# CONNECTION INFORMATION
# ===================================================================

output "connection_details" {
  description = "Connection details for accessing services"
  value = {
    # Cloud SQL connection
    sql_connection_command = "gcloud sql connect ${google_sql_database_instance.postgres.name} --user=${google_sql_user.etl_user.name} --database=${google_sql_database.etl_database.name}"
    sql_jdbc_url           = "jdbc:postgresql://${google_sql_database_instance.postgres.private_ip_address}:5432/${google_sql_database.etl_database.name}"

    # Dataproc commands
    dataproc_ssh_command = "gcloud compute ssh ${google_dataproc_cluster.etl_cluster.cluster_config[0].master_config[0].instance_names[0]} --zone=${var.data_region}-a"
    dataproc_job_submit  = "gcloud dataproc jobs submit pyspark --cluster=${google_dataproc_cluster.etl_cluster.name} --region=${var.data_region}"

    # BigQuery access
    bigquery_query_command = "bq query --use_legacy_sql=false"
    bigquery_dataset_url   = "https://console.cloud.google.com/bigquery?project=${var.project_id}&p=${var.project_id}&d=${google_bigquery_dataset.sales_analytics.dataset_id}"

    # Network information
    vpc_name            = google_compute_network.etl_vpc.name
    public_subnet_cidr  = google_compute_subnetwork.public_subnet.ip_cidr_range
    private_subnet_cidr = google_compute_subnetwork.private_subnet.ip_cidr_range
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
      "export BUCKET_NAME=${google_storage_bucket.data_bucket.name}",
      "export COMPOSER_BUCKET=${google_composer_environment.etl_composer.config[0].dag_gcs_prefix}",
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