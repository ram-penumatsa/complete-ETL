# ETL Infrastructure Design Document

## System Architecture Overview

This document outlines the technical design and architectural decisions for a production-ready ETL pipeline on Google Cloud Platform. The design follows cloud-native principles with emphasis on security, scalability, and maintainability.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        ORCHESTRATION LAYER                      │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │           Cloud Composer (Apache Airflow)                   │ │
│  │  - Workflow Management  - Job Scheduling  - Monitoring      │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────┐
│                       PROCESSING LAYER                          │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              Dataproc Cluster (Apache Spark)                │ │
│  │  - PySpark Jobs  - Data Transformation  - Analytics        │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────┐
│                        STORAGE LAYER                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Cloud Storage │  │   Cloud SQL     │  │   BigQuery      │  │
│  │   (Data Lake)   │  │  (PostgreSQL)   │  │ (Data Warehouse)│  │
│  │  - Raw Data     │  │ - Transactional │  │ - Analytics     │  │
│  │  - Staging      │  │ - Metadata      │  │ - Reporting     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────┐
│                      NETWORKING LAYER                           │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                     Custom VPC                              │ │
│  │  - Private Subnets  - Public Subnets  - NAT Gateway        │ │
│  │  - Firewall Rules  - Service Networking                    │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Design Principles

### 1. **Security by Design**
- **Zero Trust Network Model**: All components communicate through private networks
- **Principle of Least Privilege**: IAM roles with minimal required permissions
- **Defense in Depth**: Multiple layers of security controls
- **Secrets Management**: Centralized credential storage using Secret Manager

### 2. **Cloud-Native Architecture**
- **Managed Services**: Leveraging Google Cloud managed services for reduced operational overhead
- **Serverless Where Possible**: Auto-scaling and pay-per-use components
- **Infrastructure as Code**: Complete infrastructure defined in Terraform
- **Immutable Infrastructure**: Infrastructure changes through code versions

### 3. **Scalability and Performance**
- **Horizontal Scaling**: Auto-scaling clusters based on workload
- **Data Partitioning**: Strategic data organization for performance
- **Resource Optimization**: Preemptible instances and lifecycle policies
- **Multi-Region Support**: Configurable deployment across regions

### 4. **Observability and Monitoring**
- **Comprehensive Logging**: Built-in logging across all components
- **Monitoring Integration**: Native GCP monitoring and alerting
- **Audit Trails**: Complete audit logging for compliance
- **Performance Metrics**: Real-time performance monitoring

## Component Design

### Networking Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Custom VPC                              │
│                                                                 │
│  ┌─────────────────────┐    ┌─────────────────────────────────┐  │
│  │   Public Subnet     │    │      Private Subnet             │  │
│  │  (Orchestration)    │    │    (Data Processing)            │  │
│  │                     │    │                                 │  │
│  │ ┌─────────────────┐ │    │ ┌─────────────────────────────┐ │  │
│  │ │ Cloud Composer  │ │    │ │      Dataproc Cluster      │ │  │
│  │ │   Environment   │ │    │ │                             │ │  │
│  │ └─────────────────┘ │    │ └─────────────────────────────┘ │  │
│  │                     │    │                                 │  │
│  │                     │    │ ┌─────────────────────────────┐ │  │
│  │                     │    │ │       Cloud SQL             │ │  │
│  │                     │    │ │     (Private IP)            │ │  │
│  │                     │    │ └─────────────────────────────┘ │  │
│  └─────────────────────┘    └─────────────────────────────────┘  │
│                                           │                     │
│                                    ┌─────────────┐               │
│                                    │ NAT Gateway │               │
│                                    └─────────────┘               │
└─────────────────────────────────────────────────────────────────┘
```

**Design Rationale:**
- **Network Isolation**: Separate subnets for different workload types
- **Internet Access Control**: NAT gateway for controlled outbound access
- **Private Google Access**: Direct communication with Google APIs without internet
- **Service Networking**: VPC peering for private database connections

### Data Storage Architecture

#### **1. Data Lake (Cloud Storage)**
```
Data Bucket Structure:
├── sales_data/
│   └── sales_data.csv
├── reference_data/
│   ├── products.csv
│   └── stores.csv
├── pyspark-jobs/
│   └── sales_analytics_direct.py
└── jars/
    ├── spark-bigquery-with-dependencies_2.12-0.25.2.jar
    └── postgresql-42.7.1.jar

Staging Bucket:
├── temporary_processing/
├── dataproc_staging/
└── intermediate_results/
```

**Design Features:**
- **Lifecycle Management**: Automatic tier transitions (Standard → Nearline → Coldline)
- **Versioning**: Enabled for data lineage and recovery
- **Uniform Bucket-Level Access**: Simplified permission management
- **Regional Storage**: Co-located with compute for performance

#### **2. Transactional Database (Cloud SQL PostgreSQL)**
**Configuration:**
- **Private IP Only**: No public internet access
- **VPC Peering**: Secure connection from processing cluster
- **Automated Backups**: Point-in-time recovery capability
- **High Availability**: Optional for production environments

#### **3. Data Warehouse (BigQuery)**
**Design:**
- **Columnar Storage**: Optimized for analytical queries
- **Automatic Scaling**: Serverless query processing
- **Access Control**: Dataset-level permissions with IAM integration
- **Cost Optimization**: Partitioning and clustering strategies

### Processing Engine Design

#### **Dataproc Cluster Configuration**
```
Cluster Architecture:
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Master Node    │    │  Worker Nodes   │    │ Preemptible     │
│                 │    │                 │    │ Worker Nodes    │
│ - Cluster Mgmt  │    │ - Spark Workers │    │ - Cost Saving   │
│ - Job Scheduling│    │ - Data Storage  │    │ - Fault Tolerant│
│ - Resource Mgmt │    │ - Processing    │    │ - Auto Recovery │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Scaling Strategy:**
- **Master Nodes**: Fixed single node for cluster management
- **Worker Nodes**: Configurable based on workload requirements
- **Preemptible Workers**: Cost-optimized nodes for batch processing
- **Auto-scaling**: Dynamic scaling based on job queue and resource utilization

### Orchestration Design

#### **Cloud Composer Architecture**
```
Composer Environment:
┌─────────────────────────────────────────────────────────────────┐
│                    Airflow Components                           │
│                                                                 │
│ ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────┐ │
│ │ Scheduler   │  │ Web Server  │  │   Workers   │  │ Database│ │
│ │             │  │             │  │             │  │         │ │
│ │ - DAG Parse │  │ - UI/API    │  │ - Task Exec │  │ - State │ │
│ │ - Task Sched│  │ - Monitoring│  │ - Parallel  │  │ - Logs  │ │
│ └─────────────┘  └─────────────┘  └─────────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**Configuration Management:**
- **Environment Variables**: Infrastructure configuration passed to DAGs
- **Connection Management**: Secure connections to all GCP services
- **Resource Allocation**: Configurable CPU/memory for each component
- **Auto-scaling**: Worker nodes scale based on task queue

## Security Design

### Identity and Access Management (IAM)

```
Service Account Hierarchy:
┌─────────────────────────────────────────────────────────────────┐
│                    Service Accounts                             │
│                                                                 │
│ ┌─────────────────┐              ┌─────────────────────────────┐ │
│ │  Composer SA    │              │       Dataproc SA           │ │
│ │                 │              │                             │ │
│ │ Roles:          │              │ Roles:                      │ │
│ │ - Composer      │              │ - Dataproc Worker          │ │
│ │ - Dataproc Edit │              │ - Storage Admin            │ │
│ │ - Storage Admin │              │ - BigQuery Data Editor     │ │
│ │ - BigQuery Admin│              │ - BigQuery Job User        │ │
│ │ - CloudSQL Clnt │              │ - CloudSQL Client          │ │
│ └─────────────────┘              └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Network Security

**Firewall Rules Design:**
- **Default Deny**: Implicit deny-all baseline
- **Least Privilege**: Specific port/protocol combinations
- **Source Restrictions**: Limited source IP ranges
- **Tag-Based**: Resource targeting through network tags

**Key Firewall Rules:**
```
Rule Name                 | Ports      | Source           | Target
allow-internal           | All        | VPC CIDR blocks  | All instances
allow-ssh               | 22         | 0.0.0.0/0        | ssh-access tag
allow-composer          | 443, 80    | 0.0.0.0/0        | composer-access tag
allow-cloudsql          | 5432, 3306 | Private subnet   | cloudsql-access tag
allow-dataproc          | 8088, 9870 | Private/Public   | dataproc-cluster tag
```

### Secrets Management

**Secret Manager Integration:**
- **Centralized Storage**: All credentials in Secret Manager
- **Access Control**: Service account-based access
- **Rotation Support**: Automated credential rotation capability
- **Audit Logging**: Complete access audit trails

## Data Flow Design

### ETL Pipeline Architecture

```
Data Flow Sequence:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Extract   │───▶│ Transform   │───▶│    Load     │───▶│   Analyze   │
│             │    │             │    │             │    │             │
│ - File Ing  │    │ - Spark Job │    │ - BigQuery  │    │ - BI Tools  │
│ - Data Val  │    │ - Join/Agg  │    │ - Indexing  │    │ - Reports   │
│ - Quality   │    │ - Cleansing │    │ - Partition │    │ - Dashboards│
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

**Detailed Data Flow:**

1. **Data Ingestion**
   - Raw files uploaded to GCS data bucket
   - File validation and format verification
   - Metadata extraction and cataloging

2. **Data Processing**
   - Dataproc Spark jobs triggered by Composer
   - Data transformation and business logic application
   - Quality checks and data validation

3. **Data Loading**
   - Processed data loaded to BigQuery
   - Table partitioning and clustering applied
   - Indexes and views created for performance

4. **Orchestration Flow**
   - Composer DAGs monitor and coordinate
   - Error handling and retry mechanisms
   - Success/failure notifications

## Configuration Management

### Environment-Specific Configuration

```
Configuration Hierarchy:
┌─────────────────────────────────────────────────────────────────┐
│                    Variables Structure                          │
│                                                                 │
│ Global Variables:          Environment Variables:               │
│ ├── project_id            ├── dev/                             │
│ ├── default_region        │   ├── terraform.tfvars            │
│ ├── data_region           │   └── environment = "dev"         │
│ └── orchestration_region  ├── staging/                        │
│                           │   ├── terraform.tfvars            │
│ Resource Sizing:          │   └── environment = "staging"     │
│ ├── *_machine_type        └── production/                     │
│ ├── *_disk_size               ├── terraform.tfvars            │
│ └── *_node_count              └── environment = "production"  │
└─────────────────────────────────────────────────────────────────┘
```

### Deployment Configuration

**Multi-Environment Support:**
- **Variable-driven**: All configuration through Terraform variables
- **Environment isolation**: Separate state files per environment
- **Resource naming**: Environment prefixes for all resources
- **Scaling differences**: Different resource sizes per environment

## Performance and Scalability Design

### Compute Scaling Strategy

**Auto-scaling Configuration:**
- **Dataproc**: Primary and preemptible worker auto-scaling
- **Composer**: Worker node scaling based on task queue
- **BigQuery**: Automatic query scaling and slot allocation

### Storage Optimization

**Lifecycle Management:**
- **Immediate**: Standard storage for active data
- **30 days**: Transition to Nearline storage
- **90 days**: Transition to Coldline storage
- **Staging cleanup**: 7-day automatic deletion

### Cost Optimization

**Cost Control Strategies:**
- **Preemptible instances**: Up to 80% cost savings for batch workloads
- **Auto-scaling**: Pay only for needed resources
- **Storage tiers**: Automatic cost optimization
- **Regional deployment**: Reduced data transfer costs

## Disaster Recovery and Backup

### Backup Strategy

**Database Backups:**
- **Automated daily backups**: Cloud SQL automatic backup
- **Point-in-time recovery**: 7-day recovery window
- **Cross-region replication**: Optional for production

**Data Lake Backups:**
- **Object versioning**: Multiple versions of critical files
- **Cross-region replication**: Disaster recovery copies
- **Lifecycle policies**: Automated backup retention

### Recovery Procedures

**Infrastructure Recovery:**
- **Infrastructure as Code**: Complete environment recreation from Terraform
- **State file backups**: Terraform state stored in Cloud Storage
- **Configuration management**: Version-controlled configuration

**Data Recovery:**
- **Database recovery**: Point-in-time restoration capability
- **File recovery**: Object versioning and cross-region copies
- **BigQuery recovery**: Query history and table snapshots

## Monitoring and Observability

### Logging Strategy

**Centralized Logging:**
- **Cloud Logging**: All component logs aggregated
- **Structured logging**: JSON format for better parsing
- **Log retention**: Configurable retention policies
- **Real-time monitoring**: Log-based alerts and metrics

### Monitoring Integration

**Performance Monitoring:**
- **Cloud Monitoring**: Native GCP metrics and dashboards
- **Custom metrics**: Application-specific performance indicators
- **Alerting**: Proactive issue detection and notification
- **SLA monitoring**: Service level agreement tracking

## Technology Selection Rationale

### Google Cloud Platform Services

**Cloud Composer vs. Self-managed Airflow:**
- ✅ Managed service reduces operational overhead
- ✅ Built-in security and compliance features
- ✅ Auto-scaling and high availability
- ✅ Integration with GCP services

**Dataproc vs. Dataflow:**
- ✅ Spark ecosystem compatibility
- ✅ Custom library support
- ✅ Cost control with preemptible instances
- ✅ Familiar Spark/Hadoop tooling

**BigQuery vs. Self-managed Data Warehouse:**
- ✅ Serverless architecture
- ✅ Automatic scaling and optimization
- ✅ Built-in ML capabilities
- ✅ Pay-per-query pricing model

**Cloud SQL vs. Self-managed PostgreSQL:**
- ✅ Managed patches and updates
- ✅ Automated backups and high availability
- ✅ Built-in security features
- ✅ Integration with VPC and IAM

## Future Enhancement Considerations

### Scalability Improvements
- **Multi-region deployment**: Global data processing capabilities
- **Streaming data support**: Real-time data ingestion and processing
- **Advanced analytics**: ML/AI integration for predictive analytics
- **Data catalog**: Automated data discovery and lineage

### Security Enhancements
- **Customer-managed encryption**: Enhanced data encryption control
- **Private Google Access**: Eliminate internet dependencies
- **VPC Service Controls**: Perimeter security for sensitive data
- **Advanced threat detection**: ML-based security monitoring

### Operational Improvements
- **GitOps integration**: Automated deployment pipelines
- **Infrastructure testing**: Automated infrastructure validation
- **Cost optimization**: Advanced cost monitoring and optimization
- **Performance tuning**: Automated performance optimization 