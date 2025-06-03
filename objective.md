# ETL Infrastructure Objective

## Project Overview

This project is a **complete, production-ready ETL (Extract, Transform, Load) pipeline** on Google Cloud Platform using Infrastructure as Code (Terraform). The infrastructure is designed to process sales analytics data with enterprise-grade security, scalability, and reliability.

## Business Objective

The primary goal is to build a robust data pipeline that:

- **Ingests** sales data, product information, and store data from various sources
- **Transforms** and processes this data using distributed computing (Apache Spark)
- **Loads** the processed analytics results into a data warehouse for business intelligence
- **Orchestrates** the entire workflow with automated scheduling and monitoring

## Architecture Components

### 1. **Networking & Security Foundation**
- **Custom VPC** with public and private subnets for network isolation
- **NAT Gateway** for secure internet access from private resources
- **Firewall rules** implementing principle of least privilege
- **Private Google Access** for secure communication with Google APIs

### 2. **Data Ingestion & Storage**
- **Google Cloud Storage (GCS)** buckets serving as a data lake
  - Main data bucket for raw sales, products, and stores data
  - Staging bucket for temporary processing artifacts
- **Automated lifecycle management** for cost optimization (Nearline → Coldline storage)

### 3. **Data Processing Engine**
- **Google Dataproc cluster** running Apache Spark for distributed data processing
- **PySpark jobs** for sales analytics transformations
- **Auto-scaling** with preemptible instances for cost efficiency
- **Private networking** for enhanced security

### 4. **Data Warehouse & Analytics**
- **Google BigQuery** dataset for storing processed analytics results
- **Optimized for OLAP** queries and business intelligence tools
- **Role-based access control** for data governance

### 5. **Database Layer**
- **Google Cloud SQL (PostgreSQL)** for transactional data storage
- **Private IP** configuration for security
- **Automated backups** and high availability options

### 6. **Workflow Orchestration**
- **Google Cloud Composer** (managed Apache Airflow) for workflow management
- **Automated scheduling** and monitoring of ETL jobs
- **Environment variables** for configuration management
- **Integration** with all pipeline components

### 7. **Security & Compliance**
- **Google Secret Manager** for secure credential storage
- **Service accounts** with minimal required permissions
- **IAM roles and policies** following security best practices
- **VPC peering** for private database connections

## Technical Specifications

### Infrastructure Components:
- **Compute**: Dataproc cluster with configurable master/worker nodes
- **Storage**: Multi-tier GCS buckets with lifecycle policies
- **Database**: Cloud SQL PostgreSQL with private networking
- **Orchestration**: Cloud Composer v2 environment
- **Analytics**: BigQuery dataset with access controls

### Security Features:
- Private networking with NAT gateway
- Service account authentication
- Secret Manager integration
- Firewall rules and network policies
- VPC peering for database access

### Scalability & Performance:
- Auto-scaling Dataproc clusters
- Preemptible instances for cost optimization
- Multi-region deployment capability
- Lifecycle management for storage optimization

## Environment Configuration

The infrastructure supports multiple environments (dev, staging, production) through:
- **Variable-driven configuration** for environment-specific settings
- **Resource naming conventions** with environment prefixes
- **Separate service accounts** and IAM roles per environment
- **Configurable resource sizing** based on workload requirements

## Data Flow Architecture

1. **Extract**: Raw data files uploaded to GCS data bucket
2. **Transform**: Dataproc Spark jobs process and enrich the data
3. **Load**: Processed data loaded into BigQuery for analytics
4. **Orchestrate**: Cloud Composer manages the entire workflow
5. **Monitor**: Built-in logging and monitoring across all components

## Benefits

- **Scalability**: Handle growing data volumes with auto-scaling compute
- **Security**: Enterprise-grade security with private networking and IAM
- **Cost Optimization**: Lifecycle policies and preemptible instances
- **Reliability**: High availability and automated backup strategies
- **Maintainability**: Infrastructure as Code for version control and reproducibility
- **Flexibility**: Support for multiple data formats and processing patterns

## Use Cases

This infrastructure is ideal for:
- Sales analytics and reporting
- Customer behavior analysis
- Product performance tracking
- Store operations optimization
- Business intelligence and data science workflows
- Real-time and batch data processing scenarios

## Deployment Strategy

The infrastructure is designed for:
- **Multi-environment deployment** (dev/staging/production)
- **Infrastructure as Code** best practices
- **Automated provisioning** and configuration management
- **Version-controlled infrastructure** changes
- **Disaster recovery** and backup strategies 