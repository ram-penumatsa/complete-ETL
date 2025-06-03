"""
Sales Analytics ETL DAG
Orchestrates the complete ETL pipeline using Cloud Composer (Airflow)
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.google.cloud.operators.dataproc import (
    DataprocSubmitJobOperator,
    DataprocCreateClusterOperator,
    DataprocDeleteClusterOperator
)
from airflow.operators.python import PythonOperator
from airflow.operators.dummy import DummyOperator
import os

# Environment variables from Composer configuration
PROJECT_ID = os.getenv('PYSPARK_PROJECT_ID')
REGION = os.getenv('REGION')
DATAPROC_CLUSTER = os.getenv('DATAPROC_CLUSTER')
DATA_BUCKET = os.getenv('DATA_BUCKET')
BIGQUERY_DATASET = os.getenv('BIGQUERY_DATASET')
ENVIRONMENT = os.getenv('ENVIRONMENT', 'dev')

# Cloud SQL connection variables (added for private IP connectivity)
CLOUDSQL_IP = os.getenv('CLOUDSQL_IP')
DATABASE_NAME = os.getenv('DATABASE_NAME')
DATABASE_USER = os.getenv('DATABASE_USER')

# DAG default arguments
default_args = {
    'owner': 'data-engineering-team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=5),
    'max_active_runs': 1,
}

# Create DAG
dag = DAG(
    'sales_analytics_etl',
    default_args=default_args,
    description='Sales Analytics ETL Pipeline with PySpark and BigQuery',
    schedule_interval='@daily',
    catchup=False,
    tags=['etl', 'sales', 'analytics', 'pyspark', 'bigquery']
)

# ===================================================================
# PYSPARK ETL JOB
# ===================================================================

# PySpark job configuration
pyspark_job = {
    "reference": {"project_id": PROJECT_ID},
    "placement": {"cluster_name": DATAPROC_CLUSTER},
    "pyspark_job": {
        "main_python_file_uri": f"gs://{DATA_BUCKET}/pyspark-jobs/sales_analytics_direct.py",
        "args": [
            "--project-id", PROJECT_ID,
            "--region", REGION,
            "--data-bucket", DATA_BUCKET,
            "--cloudsql-ip", CLOUDSQL_IP,
            "--database-name", DATABASE_NAME,
            "--database-user", DATABASE_USER,
            "--bigquery-dataset", BIGQUERY_DATASET,
            "--environment", ENVIRONMENT,
            "--sql-password-secret", "dev-sql-password"
        ],
        "python_file_uris": [
            f"gs://{DATA_BUCKET}/pyspark-jobs/database_utils.py"
        ],
        "jar_file_uris": [
            f"gs://{DATA_BUCKET}/jars/spark-bigquery-with-dependencies_2.12-0.25.2.jar",
            f"gs://{DATA_BUCKET}/jars/postgresql-42.7.1.jar"
        ],
        "properties": {
            "spark.executor.memory": "4g",
            "spark.executor.cores": "2",
            "spark.driver.memory": "2g",
            "spark.sql.adaptive.enabled": "true",
            "spark.sql.adaptive.coalescePartitions.enabled": "true",
            "spark.eventLog.enabled": "false",
            # Environment variables for PySpark job
            "spark.executorEnv.PYSPARK_PROJECT_ID": PROJECT_ID,
            "spark.executorEnv.REGION": REGION,
            "spark.executorEnv.DATA_BUCKET": DATA_BUCKET,
            "spark.executorEnv.CLOUDSQL_IP": CLOUDSQL_IP,
            "spark.executorEnv.DATABASE_NAME": DATABASE_NAME,
            "spark.executorEnv.DATABASE_USER": DATABASE_USER,
            "spark.executorEnv.BIGQUERY_DATASET": BIGQUERY_DATASET,
            "spark.executorEnv.ENVIRONMENT": ENVIRONMENT,
            "spark.executorEnv.SQL_PASSWORD_SECRET": "dev-sql-password",
            "spark.driverEnv.PYSPARK_PROJECT_ID": PROJECT_ID,
            "spark.driverEnv.REGION": REGION,
            "spark.driverEnv.DATA_BUCKET": DATA_BUCKET,
            "spark.driverEnv.CLOUDSQL_IP": CLOUDSQL_IP,
            "spark.driverEnv.DATABASE_NAME": DATABASE_NAME,
            "spark.driverEnv.DATABASE_USER": DATABASE_USER,
            "spark.driverEnv.BIGQUERY_DATASET": BIGQUERY_DATASET,
            "spark.driverEnv.ENVIRONMENT": ENVIRONMENT,
            "spark.driverEnv.SQL_PASSWORD_SECRET": "dev-sql-password"
        }
    }
}

# Submit PySpark job to Dataproc
run_sales_analytics = DataprocSubmitJobOperator(
    task_id='run_sales_analytics_etl',
    job=pyspark_job,
    region=REGION,
    project_id=PROJECT_ID,
    dag=dag
)

# ===================================================================
# WORKFLOW ORCHESTRATION
# ===================================================================

# Start and end tasks
start_pipeline = DummyOperator(
    task_id='start_pipeline',
    dag=dag
)

end_pipeline = DummyOperator(
    task_id='end_pipeline',
    dag=dag
)

# Define task dependencies
start_pipeline >> run_sales_analytics >> end_pipeline

# ===================================================================
# DAG DOCUMENTATION
# ===================================================================

dag.doc_md = """
# Sales Analytics ETL Pipeline

This DAG orchestrates a complete ETL pipeline for sales analytics processing.

## Pipeline Steps:

1. **ETL Processing**: Run PySpark job to process sales data

## Data Flow:
- **Input**: Sales CSV data from GCS
- **Processing**: PySpark on Dataproc cluster
- **Output**: Analytics tables in BigQuery

## Monitoring:
- Check Airflow logs for task execution details
- Monitor Dataproc job progress in GCP Console
- Verify results in BigQuery Console

## Schedule: 
- Runs daily at midnight UTC
- No automatic retries on failure
- Single active run at a time
""" 