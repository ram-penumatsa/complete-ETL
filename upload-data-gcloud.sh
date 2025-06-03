#!/bin/bash
# Upload Data Script - Fast GCS Setup (using gcloud storage)
# Creates folder structure and uploads all required files

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get bucket name from Terraform
BUCKET_NAME=$(terraform output -raw data_bucket_name 2>/dev/null)
COMPOSER_BUCKET=$(terraform output -raw composer_gcs_bucket 2>/dev/null)

if [ -z "$BUCKET_NAME" ]; then
    echo -e "${RED}❌ Could not get bucket name from Terraform${NC}"
    exit 1
fi

if [ -z "$COMPOSER_BUCKET" ]; then
    echo -e "${RED}❌ Could not get Composer bucket from Terraform${NC}"
    exit 1
fi

echo -e "${GREEN}🚀 Uploading data to bucket: $BUCKET_NAME${NC}"
echo -e "${GREEN}🚀 Uploading DAGs to bucket: $COMPOSER_BUCKET${NC}"

# Create folder structure (using touch and upload)
echo -e "${YELLOW}📁 Creating folder structure...${NC}"
touch .keep
gcloud storage cp .keep gs://$BUCKET_NAME/sales_data/
gcloud storage cp .keep gs://$BUCKET_NAME/reference_data/
gcloud storage cp .keep gs://$BUCKET_NAME/jars/
gcloud storage cp .keep gs://$BUCKET_NAME/pyspark-jobs/
gcloud storage cp .keep gs://$BUCKET_NAME/docs/
rm .keep

# Upload CSV files
echo -e "${YELLOW}📊 Uploading CSV files...${NC}"
if [ -f "sample_data/sales_data/sales_data.csv" ]; then
    gcloud storage cp sample_data/sales_data/sales_data.csv gs://$BUCKET_NAME/sales_data/
    echo -e "${GREEN}✅ Sales data uploaded${NC}"
else
    echo -e "${RED}❌ Sales CSV not found${NC}"
fi

if [ -f "sample_data/reference_data/products.csv" ]; then
    gcloud storage cp sample_data/reference_data/products.csv gs://$BUCKET_NAME/reference_data/
    echo -e "${GREEN}✅ Products data uploaded${NC}"
else
    echo -e "${RED}❌ Products CSV not found${NC}"
fi

if [ -f "sample_data/reference_data/stores.csv" ]; then
    gcloud storage cp sample_data/reference_data/stores.csv gs://$BUCKET_NAME/reference_data/
    echo -e "${GREEN}✅ Stores data uploaded${NC}"
else
    echo -e "${RED}❌ Stores CSV not found${NC}"
fi

# Upload JAR files
echo -e "${YELLOW}📦 Uploading JAR files...${NC}"
if [ -d "jars" ] && [ -n "$(ls -A jars/*.jar 2>/dev/null)" ]; then
    gcloud storage cp jars/*.jar gs://$BUCKET_NAME/jars/
    echo -e "${GREEN}✅ JAR files uploaded${NC}"
else
    echo -e "${RED}❌ JAR files not found in jars/ directory${NC}"
fi

# Upload PySpark job
echo -e "${YELLOW}🐍 Uploading PySpark job...${NC}"
if [ -f "pyspark-jobs/sales_analytics_direct.py" ]; then
    gcloud storage cp pyspark-jobs/sales_analytics_direct.py gs://$BUCKET_NAME/pyspark-jobs/
    echo -e "${GREEN}✅ PySpark job uploaded${NC}"
else
    echo -e "${RED}❌ PySpark job not found${NC}"
fi

if [ -f "pyspark-jobs/database_utils.py" ]; then
    gcloud storage cp pyspark-jobs/database_utils.py gs://$BUCKET_NAME/pyspark-jobs/
    echo -e "${GREEN}✅ Database utils uploaded${NC}"
fi

# Upload Airflow DAGs
echo -e "${YELLOW}🌬️  Uploading Airflow DAGs...${NC}"
if [ -f "dags/sales_etl_dag.py" ]; then
    gcloud storage cp dags/sales_etl_dag.py ${COMPOSER_BUCKET}/sales_etl_dag.py
    echo -e "${GREEN}✅ DAG files uploaded${NC}"
else
    echo -e "${RED}❌ DAG file not found: dags/sales_etl_dag.py${NC}"
fi

# Upload documentation
echo -e "${YELLOW}📖 Uploading documentation...${NC}"
for doc in README.md SECRET_MANAGEMENT.md DEPLOYMENT_GUIDE.md; do
    if [ -f "$doc" ]; then
        gcloud storage cp "$doc" gs://$BUCKET_NAME/docs/
        echo -e "${GREEN}✅ $doc uploaded${NC}"
    fi
done

# Verify uploads
echo -e "${YELLOW}🔍 Verifying uploads...${NC}"
echo ""
echo -e "${GREEN}📊 Data files:${NC}"
gcloud storage ls gs://$BUCKET_NAME/sales_data/
gcloud storage ls gs://$BUCKET_NAME/reference_data/

echo ""
echo -e "${GREEN}📦 JAR files:${NC}"
gcloud storage ls gs://$BUCKET_NAME/jars/

echo ""
echo -e "${GREEN}🐍 PySpark files:${NC}"
gcloud storage ls gs://$BUCKET_NAME/pyspark-jobs/

echo ""
echo -e "${GREEN}🌬️  DAG files:${NC}"
gcloud storage ls ${COMPOSER_BUCKET}/

echo ""
echo -e "${GREEN}🎉 Upload completed successfully!${NC}"
echo -e "${GREEN}Bucket structure created and all files uploaded to: gs://$BUCKET_NAME${NC}" 