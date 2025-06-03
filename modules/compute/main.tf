# ===================================================================
# COMPUTE MODULE - DATAPROC CLUSTER
# ===================================================================

# Dataproc cluster for PySpark processing
resource "google_dataproc_cluster" "etl_cluster" {
  name   = var.dataproc_cluster_name
  region = var.data_region

  cluster_config {
    staging_bucket = var.staging_bucket_name

    master_config {
      num_instances = var.dataproc_master_nodes
      machine_type  = var.dataproc_master_machine_type
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = var.dataproc_master_disk_size
      }
    }

    worker_config {
      num_instances = var.dataproc_worker_nodes
      machine_type  = var.dataproc_worker_machine_type
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = var.dataproc_worker_disk_size
      }
    }

    preemptible_worker_config {
      num_instances = var.dataproc_preemptible_nodes
    }

    software_config {
      image_version = var.dataproc_image_version
    }

    gce_cluster_config {
      subnetwork       = var.private_subnet_name
      internal_ip_only = true

      service_account = var.dataproc_service_account_email
      service_account_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]

      tags = ["dataproc-cluster", var.environment, "ssh-access"]
    }
  }

  labels = {
    environment = var.environment
    purpose     = "etl-processing"
    managed_by  = "terraform"
  }
} 