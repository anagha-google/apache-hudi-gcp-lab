
'''
 Copyright 2022 Google LLC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
'''

# ======================================================================================
# ABOUT
# This script orchestrates the execution of the HUDI table syncing
# in dataproc GCE cluster created at DAG execution time
# ======================================================================================

import os
from datetime import datetime
from google.protobuf.duration_pb2 import Duration
import string
import random

from airflow.models import Variable
from airflow import models
from airflow.providers.google.cloud.operators.dataproc import (
    DataprocCreateClusterOperator,
    DataprocDeleteClusterOperator,
    DataprocSubmitJobOperator,
)
from airflow.utils.dates import days_ago
from airflow.utils import trigger_rule
from airflow.operators import dummy_operator


# Read environment variables into local variables
project_id = models.Variable.get("project_id")
project_nbr = models.Variable.get("project_nbr")
umsa_fqn=Variable.get("umsa_fqn")
dataproc_location=Variable.get("dataproc_location")
hudi_table_name=Variable.get("hudi_table_name")
hudi_base_path=Variable.get("hudi_base_path")
hudi_table_source_uri=Variable.get("hudi_table_source_uri")
hudi_partition_key=Variable.get("hudi_partition_key")
bq_dataset_name=Variable.get("bq_dataset_name")
bq_dataset_location=Variable.get("bq_dataset_location")
bq_table_name=Variable.get("bq_table_name")
subnet_uri=f"projects/{project_id}/regions/{dataproc_location}/subnetworks/gaia-spark-snet"

# Other variables
dag_name="hudi_table_bq_sync"
dpgce_cluster_name="dpgce-cluster-ephemeral-"+project_nbr
dpgce_cluster_bucket_name="gaia_dataproc_bucket-"+project_nbr
dpgce_cluster_region=dataproc_location
dpgce_cluster_master_type='n1-standard-4'
dpgce_cluster_worker_type='n1-standard-4'
dpgce_cluster_image_version='2.1.20-debian11'
phs_bucket_name="gaia-phs-"+project_nbr
phs_conf = {"spark:spark.history.fs.logDirectory": "gs://"+phs_bucket_name+"/*/spark-job-history",
"spark:spark.eventLog.dir":"gs://"+phs_bucket_name+"/events/spark-job-history",
"yarn:yarn.nodemanager.remote-app-log-dir":"gs://"+phs_bucket_name+"/yarn-logs",
"mapred:mapreduce.jobhistory.done-dir":"gs://"+phs_bucket_name+"/events/mapreduce-job-history/done",
"mapred:mapreduce.jobhistory.intermediate-done-dir":"gs://"+phs_bucket_name+"/events/mapreduce-job-history/intermediate-done"
}

#Set cluster timeout duration
duration = Duration()
duration.seconds = 3600

# This is to add a random suffix to the serverless Spark batch ID that needs to be unique each run
# ...Define the random module
S = 10  # number of characters in the string.
# call random.choices() string module to find the string in Uppercase + numeric data.
ran = ''.join(random.choices(string.digits, k = S))

job_id_prefix = "hudi-nyc-taxi-bq-sync-tool-exec-"+str(ran)

HUDI_BQ_SYNC_TOOL_ARGS = ["--project-id", project_id, "--dataset-name", bq_dataset_name, "--dataset-location", bq_dataset_location, "--table", bq_table_name, "--source-uri", hudi_table_source_uri, "--source-uri-prefix", hudi_base_path, "--base-path", hudi_base_path, "--partitioned-by", "trip_date", "--use-bq-manifest-file"]


NYC_TAXI_HUDI_TO_BQ_SYNC_TOOL_EXEC_CONF = {
    "reference": {"job_id": job_id_prefix,"project_id": project_id},
    "placement": {"cluster_name": dpgce_cluster_name},
    "spark_job": {
        "jar_file_uris": ["file:///usr/lib/hudi/tools/bq-sync-tool/hudi-gcp-bundle-0.12.3.jar"],
        "main_class": "org.apache.hudi.gcp.bigquery.BigQuerySyncTool",
        "properties": {"spark.jars.packages":"com.google.cloud:google-cloud-bigquery:2.10.4","spark.driver.userClassPathFirst":"true","spark.executor.userClassPathFirst":"true"},
        "args": HUDI_BQ_SYNC_TOOL_ARGS
    },
}

with models.DAG(
    dag_name,
    schedule_interval=None,
    start_date = days_ago(2),
    catchup=False,
) as dag_dataproc_cluster_job:

    start = dummy_operator.DummyOperator(
        task_id='start',
        trigger_rule='all_success'
    )

    end = dummy_operator.DummyOperator(
        task_id='end',
        trigger_rule='all_done'
    )
  
    create_dpgce_cluster = DataprocCreateClusterOperator(
        task_id="Create_Dataproc_GCE_Cluster",
        project_id=project_id,
        cluster_name=dpgce_cluster_name,
        region=dataproc_location,
        cluster_config={
            "gce_cluster_config" : {
                "service_account": umsa_fqn,
                "subnetwork_uri": subnet_uri,
                "service_account_scopes": ["https://www.googleapis.com/auth/cloud-platform"],
                "internal_ip_only": True
            },
            "master_config": {
                "num_instances": 1,
                "machine_type_uri": dpgce_cluster_master_type,
                "disk_config": {"boot_disk_type": "pd-standard", "boot_disk_size_gb": 1024},
            },
            "worker_config": {
                "num_instances": 2,
                "machine_type_uri": dpgce_cluster_worker_type,
                "disk_config": {"boot_disk_type": "pd-standard", "boot_disk_size_gb": 1024},
            },
            "software_config": {
                "image_version": dpgce_cluster_image_version,
                "properties": phs_conf,
                "optional_components": ["HUDI"]
            },
            "lifecycle_config": {
                "idle_delete_ttl": duration,
            },
            "endpoint_config": {
                "enable_http_port_access": True
            }
        }
    )
  
    exec_bq_sync_tool_nyc_taxi_cow = DataprocSubmitJobOperator(
        task_id="Exec-HudiBigQueryTool-NYCTaxi_Cow",
        project_id=project_id,
        region=dpgce_cluster_region,
        job=NYC_TAXI_HUDI_TO_BQ_SYNC_TOOL_EXEC_CONF,
        impersonation_chain=umsa_fqn
    )
  
    delete_cluster=DataprocDeleteClusterOperator(
        task_id="Delete_DPGCE_Cluster",
        project_id=project_id,
        region=dpgce_cluster_region,
        cluster_name=dpgce_cluster_name,
        trigger_rule=trigger_rule.TriggerRule.ALL_DONE
    )

    start >> create_dpgce_cluster >> exec_bq_sync_tool_nyc_taxi_cow
    exec_bq_sync_tool_nyc_taxi_cow >> delete_cluster >> end
