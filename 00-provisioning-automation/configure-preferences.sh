# About:
# This script creates the Terraform tfvars file upon executing

PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
PROJECT_NAME=`gcloud projects describe ${PROJECT_ID} | grep name | cut -d':' -f2 | xargs`
GCP_ACCOUNT_NAME=`gcloud auth list --filter=status:ACTIVE --format="value(account)"`
ORG_ID=`gcloud organizations list --format="value(name)"`
YOUR_GCP_REGION="us-central1"
YOUR_GCP_ZONE="${YOUR_GCP_REGION}-a"
YOUR_GCP_MULTI_REGION="US"
PROVISION_VERTEX_AI="false"
UPDATE_ORG_POLICIES="true"
DATAPROC_GCE_IMAGE_VERSION="2.1.14-debian11"
CLOUD_COMPOSER_IMG_VERSION="composer-2.3.0-airflow-2.5.1"

echo "project_id = "\"$PROJECT_ID"\"" > terraform.tfvars
echo "project_number = "\"$PROJECT_NBR"\"" >> terraform.tfvars
echo "project_name = "\"$PROJECT_NAME"\"" >> terraform.tfvars
echo "gcp_account_name = "\"${GCP_ACCOUNT_NAME}"\"" >> terraform.tfvars
echo "org_id = "\"${ORG_ID}"\"" >> terraform.tfvars

echo "dataproc_gce_image_version = "\"${DATAPROC_GCE_IMAGE_VERSION}"\"" >> terraform.tfvars
echo "cloud_composer_image_version = "\"${CLOUD_COMPOSER_IMG_VERSION}"\"" >> terraform.tfvars
echo "gcp_region = "\"${YOUR_GCP_REGION}"\"" >> terraform.tfvars
echo "gcp_zone = "\"${YOUR_GCP_ZONE}"\"" >> terraform.tfvars
echo "gcp_multi_region = "\"${YOUR_GCP_MULTI_REGION}"\"" >> terraform.tfvars
echo "provision_vertex_ai_bool = "\"$PROVISION_VERTEX_AI"\"" >> terraform.tfvars 
echo "update_org_policies_bool = "\"$UPDATE_ORG_POLICIES"\"" >> terraform.tfvars 

