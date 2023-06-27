resource "google_composer_environment" "create_cloud_composer_env" {
  name   = "${local.project_id}-cc2"
  region = local.location
  project = local.project_id
  config {
    software_config {
      image_version = local.cloud_composer_img_version 
      env_variables = {
        AIRFLOW_VAR_GCP_ACCOUNT_NAME = "${local.admin_upn_fqn}"
      }
    }

    node_config {
      network    = local.vpc_nm
      subnetwork = local.catchall_subnet_nm
      service_account = local.umsa_fqn
    }
  }

  depends_on = [
        time_sleep.sleep_after_network_and_storage_steps,
        time_sleep.sleep_after_creating_dpgce  
  ] 

  timeouts {
    create = "75m"
  } 
}

output "CLOUD_COMPOSER_DAG_BUCKET" {
  value = google_composer_environment.create_cloud_composer_env.config.0.dag_gcs_prefix
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/


resource "time_sleep" "sleep_after_creating_composer" {
  create_duration = "180s"
  depends_on = [
      google_composer_environment.create_cloud_composer_env
  ]
}


/*******************************************
Upload the Airflow DAG available locally to the DAG bucket created by Cloud Composer
********************************************/

variable "airflow_dags_to_upload" {
  type = map(string)
  default = {
    "../01-scripts/airflow/nyc_taxi_trips/data_engineering_pipeline.py" = "dags/nyc_taxi_trips/data_engineering_pipeline.py",
  }
}

resource "google_storage_bucket_object" "upload_dags_to_airflow_dag_bucket" {
  for_each = var.airflow_dags_to_upload
  name     = each.value
  source   = "${path.module}/${each.key}"
  bucket   = substr(substr(google_composer_environment.create_cloud_composer_env.config.0.dag_gcs_prefix, 5, length(google_composer_environment.create_cloud_composer_env.config.0.dag_gcs_prefix)), 0, (length(google_composer_environment.create_cloud_composer_env.config.0.dag_gcs_prefix)-10))
  depends_on = [
    time_sleep.create_cloud_composer_env
  ]
}



