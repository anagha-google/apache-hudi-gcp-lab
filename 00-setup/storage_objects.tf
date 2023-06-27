variable "scripts_to_upload" {
  type = map(string)
  default = {
    "../01-scripts/airflow/data_engineering_pipeline.py" = "airflow/data_engineering_pipeline.py",
    "../01-scripts/bash/run_service_updates.sh" = "bash/run_service_updates.sh",
    "../01-scripts/bqsql/export_taxi_trips.sql" = "bqsql/export_taxi_trips.sql",
    "../01-scripts/pyspark/nyc_taxi_data_generator_parquet.py" = "pyspark/nyc_taxi_data_generator_parquet.py"
  }
}

resource "google_storage_bucket_object" "upload_scripts_to_gcs" {
  for_each = var.scripts_to_upload
  name     = each.value
  source   = "${path.module}/${each.key}"
  bucket   = "${local.code_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation
  ]
}

variable "notebooks_to_upload" {
  type = map(string)
  default = {
    "../02-notebooks/nyc_taxi_trips_data_generator/nyc_taxi_hudi_data_generator.ipynb" = "nyc_taxi_trips_data_generator/nyc_taxi_hudi_data_generator.ipynb"
  }
}
resource "google_storage_bucket_object" "upload_notebooks_to_gcs" {
  for_each = var.notebooks_to_upload
  name     = each.value
  source   = "${path.module}/${each.key}"
  bucket   = "${local.notebook_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation
  ]
}


