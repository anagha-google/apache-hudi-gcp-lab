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


