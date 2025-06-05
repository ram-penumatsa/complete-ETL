#!/bin/bash

# Terraform Destroy Script with Proper Dependency Management
# This script ensures resources are destroyed in the correct order to avoid dependency errors

set -e  # Exit on any error

echo "🔥 Starting Terraform Destroy with Proper Dependency Management"
echo "=================================================="

# Function to check if terraform command was successful
check_terraform_result() {
    if [ $? -eq 0 ]; then
        echo "✅ $1 completed successfully"
    else
        echo "❌ $1 failed"
        exit 1
    fi
}

# Function to destroy specific resource types
destroy_resource_type() {
    local resource_pattern="$1"
    local description="$2"
    
    echo ""
    echo "🎯 Destroying: $description"
    echo "Resource pattern: $resource_pattern"
    
    # Check if resources exist
    if terraform state list | grep -q "$resource_pattern"; then
        terraform destroy -target="$resource_pattern" -auto-approve
        check_terraform_result "$description destruction"
    else
        echo "ℹ️  No $description found in state"
    fi
}

# Step 1: Destroy Application Layer (Cloud Composer)
echo "📱 Phase 1: Destroying Application/Orchestration Layer"
destroy_resource_type "google_composer_environment" "Cloud Composer Environment"

# Step 2: Destroy Compute Layer (Dataproc Clusters)
echo ""
echo "💻 Phase 2: Destroying Compute Layer"
destroy_resource_type "google_dataproc_cluster" "Dataproc Clusters"

# Step 3: Destroy Data Layer (Cloud SQL, BigQuery)
echo ""
echo "🗄️  Phase 3: Destroying Data Layer"
destroy_resource_type "google_sql_user" "SQL Users"
destroy_resource_type "google_sql_database\." "SQL Databases"
destroy_resource_type "google_sql_database_instance" "SQL Instances"
destroy_resource_type "google_bigquery_dataset" "BigQuery Datasets"

# Step 4: Destroy Storage Layer (GCS Buckets)
echo ""
echo "🪣 Phase 4: Destroying Storage Layer"
destroy_resource_type "google_storage_bucket" "Storage Buckets"

# Step 5: Destroy Security Layer (IAM, Secrets)
echo ""
echo "🔐 Phase 5: Destroying Security Layer"
destroy_resource_type "google_secret_manager_secret_iam_member" "Secret Manager IAM"
destroy_resource_type "google_secret_manager_secret_version" "Secret Versions"
destroy_resource_type "google_secret_manager_secret\." "Secrets"
destroy_resource_type "google_project_iam_member" "Project IAM Members"

# Step 6: Destroy Networking Layer (Critical Order)
echo ""
echo "🌐 Phase 6: Destroying Network Layer (Critical Order)"

# First destroy firewall rules
destroy_resource_type "google_compute_firewall" "Firewall Rules"

# Then destroy NAT and Router
destroy_resource_type "google_compute_router_nat" "Cloud NAT"
destroy_resource_type "google_compute_router" "Cloud Router"

# Then destroy subnets
destroy_resource_type "google_compute_subnetwork" "Subnets"

# CRITICAL: Remove Service Networking Connection from state if it exists
# This prevents the dependency error we encountered earlier
if terraform state list | grep -q "google_service_networking_connection"; then
    echo "⚠️  Removing Service Networking Connection from Terraform state to prevent dependency issues"
    terraform state rm $(terraform state list | grep "google_service_networking_connection")
    echo "✅ Service Networking Connection removed from state"
fi

# Destroy private IP allocations
destroy_resource_type "google_compute_global_address" "Global IP Addresses"

# Finally destroy the VPC network
destroy_resource_type "google_compute_network" "VPC Networks"

# Step 7: Destroy Foundation Layer (APIs)
echo ""
echo "🏗️  Phase 7: Destroying Foundation Layer"
destroy_resource_type "google_project_service" "Project APIs"

# Step 8: Final cleanup - destroy any remaining resources
echo ""
echo "🧹 Phase 8: Final Cleanup"
echo "Checking for any remaining resources..."

remaining_resources=$(terraform state list | wc -l)
if [ $remaining_resources -gt 0 ]; then
    echo "⚠️  Found $remaining_resources remaining resources. Attempting final destroy..."
    terraform destroy -auto-approve
    check_terraform_result "Final cleanup"
else
    echo "✅ No remaining resources found"
fi

echo ""
echo "🎉 Terraform Destroy Completed Successfully!"
echo "=================================================="
echo "All resources have been destroyed in the proper order."
echo ""
echo "Next steps:"
echo "1. Verify in Google Cloud Console that all resources are deleted"
echo "2. Check for any orphaned resources that might incur costs"
echo "3. Review terraform.tfstate to ensure it's clean" 