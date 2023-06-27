/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/******************************************
Local variables declaration
 *****************************************/

locals {
resource_prefix             = "gaia"

project_id                  = "${var.project_id}"
project_nbr                 = "${var.project_number}"
admin_upn_fqn               = "${var.gcp_account_name}"
location                    = "${var.gcp_region}"
zone                        = "${var.gcp_zone}"
location_multi              = "${var.gcp_multi_region}"

# IAM principals/accounts
umsa                        = "${local.resource_prefix}-lab-sa"
umsa_fqn                    = "${local.umsa}@${local.project_id}.iam.gserviceaccount.com"
CC_GMSA_FQN                 = "service-${local.project_nbr}@cloudcomposer-accounts.iam.gserviceaccount.com"
GCE_GMSA_FQN                = "${local.project_nbr}-compute@developer.gserviceaccount.com"

# GCS buckets
dataproc_bucket             = "${local.resource_prefix}_dataproc_bucket-${local.project_nbr}"
dataproc_temp_bucket        = "${local.resource_prefix}_dataproc_temp_bucket-${local.project_nbr}"
spark_bucket                = "${local.resource_prefix}-spark-bucket-${local.project_nbr}"
spark_bucket_fqn            = "gs://${local.resource_prefix}-spark-${local.project_nbr}"
phs_bucket                  = "${local.resource_prefix}-phs-${local.project_nbr}"
phs_bucket_fqn              = "gs://${local.resource_prefix}-phs-${local.project_nbr}"
dpms_bucket                 = "${local.resource_prefix}-dpms-${local.project_nbr}"
dpms_bucket_fqn             = "gs://${local.resource_prefix}-dpms-${local.project_nbr}"
data_bucket                 = "${local.resource_prefix}_data_bucket-${local.project_nbr}"
code_bucket                 = "${local.resource_prefix}_code_bucket-${local.project_nbr}"
notebook_bucket             = "${local.resource_prefix}_notebook_bucket-${local.project_nbr}"

# Networking Deployments
vpc_nm                      = "${local.resource_prefix}-vpc-${local.project_nbr}"
spark_subnet_nm             = "${local.resource_prefix}-spark-snet"
spark_subnet_cidr           = "10.0.0.0/16"
catchall_subnet_nm          = "${local.resource_prefix}-catchall-snet"
catchall_subnet_cidr           = "10.2.0.0/16"

# BigQuery Deployments
bq_product_dataset          ="${local.resource_prefix}_product_ds"
bq_connection               ="${local.resource_prefix}_bq_connection"

# Dataplex Deployments
lake_nm="${local.resource_prefix}-data-lake"
raw_zone_nm="${local.resource_prefix}-raw-zone"
curated_zone_nm="${local.resource_prefix}-curated-zone"
product_zone_nm="${local.resource_prefix}-product-zone"

# Data Lake Service Deployments
phs_nm                      = "${local.resource_prefix}-phs-${local.project_nbr}"
dpms_nm                     = "${local.resource_prefix}-dpms-${local.project_nbr}"
dpgce_nm                    = "${local.resource_prefix}-dpgce-cpu-${local.project_nbr}"
dpgce_autoscale_policy_nm   = "${local.resource_prefix}-dpgce-cpu-autoscale-policy-${local.project_nbr}"
dataproc_gce_img_version    = "${var.dataproc_gce_image_version}"

# Cloud Composer/Apache Airflow Deployments
cloud_composer_img_version = "${var.cloud_composer_image_version}"

}

module "setup_foundations" {
    source = "./module_apis_and_policies"
    project_id = var.project_id
}
