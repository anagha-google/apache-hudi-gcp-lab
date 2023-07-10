resource "google_dataproc_autoscaling_policy" "create_autoscale_policy" {
  policy_id = local.dpgce_autoscale_policy_nm
  location  = local.location

  worker_config {
    max_instances = 5
  }

  secondary_worker_config {
    min_instances = 0
    max_instances = 10
  }

  basic_algorithm {
    yarn_config {
      graceful_decommission_timeout = "30s"
      scale_up_factor   = 0.5
      scale_down_factor = 0.5
    }
  }
  depends_on = [
    time_sleep.sleep_after_network_and_storage_steps
  ]
}

resource "google_dataproc_cluster" "create_dpgce_cluster" {
  
  name     = "${local.dpgce_nm}"
  project  = var.project_id
  region   = local.location
  cluster_config {
    staging_bucket = local.dataproc_bucket
    temp_bucket = local.dataproc_temp_bucket
    master_config {
      num_instances = 1
      machine_type  = "n1-standard-8"
      disk_config {
        boot_disk_size_gb = 1000
      }
    }

    worker_config {
      num_instances    = 4
      machine_type     = "n1-standard-8"
      disk_config {
        boot_disk_size_gb = 1000
        num_local_ssds    = 1
      }
    }
    
    preemptible_worker_config {
      num_instances = 0
    }

    endpoint_config {
        enable_http_port_access = "true"
    }

    autoscaling_config {
        policy_uri = "projects/${local.project_id}/locations/${local.location}/autoscalingPolicies/${local.dpgce_autoscale_policy_nm}"
    }

    # Override or set some custom properties
    software_config {
      image_version = local.dataproc_gce_img_version
      optional_components = [ "JUPYTER","HUDI"]
      override_properties = {
        "dataproc:dataproc.allow.zero.workers" = "false"
        "spark:spark.history.fs.logDirectory"="${local.phs_bucket_fqn}/*/spark-job-history"
        "spark:spark.eventLog.dir"="${local.phs_bucket_fqn}/events/spark-job-history"
        "mapred:mapreduce.jobhistory.read-only.dir-pattern"="${local.phs_bucket_fqn}/*/mapreduce-job-history/done"
        "mapred:mapreduce.jobhistory.done-dir"="${local.phs_bucket_fqn}/events/mapreduce-job-history/done"
        "mapred:mapreduce.jobhistory.intermediate-done-dir"="${local.phs_bucket_fqn}/events/mapreduce-job-history/intermediate-done"
        "yarn:yarn.nodemanager.remote-app-log-dir"="${local.phs_bucket_fqn}/yarn-logs"
      }
    }

    metastore_config {
        dataproc_metastore_service = "projects/${local.project_id}/locations/${local.location}/services/${local.dpms_nm}"
    }

    gce_cluster_config {
      zone        = "${local.zone}"
      subnetwork  = local.spark_subnet_nm
      service_account = local.umsa_fqn
      service_account_scopes = [
        "cloud-platform"
      ]
      internal_ip_only = true
      shielded_instance_config {
        enable_secure_boot          = true
        enable_vtpm                 = true
        enable_integrity_monitoring = true
        }
 
    }
  }
  depends_on = [
    time_sleep.sleep_after_network_and_storage_steps,
    google_dataproc_metastore_service.datalake_metastore_creation,
    google_dataproc_cluster.create_phs,
    google_dataproc_autoscaling_policy.create_autoscale_policy
  ]  
}



resource "time_sleep" "sleep_after_creating_dpgce" {
  create_duration = "120s"
  depends_on = [
   google_dataproc_cluster.create_dpgce_cluster

  ]
}
