variable "notebooks_to_upload" {
  type = map(string)
  default = {
    "../02-notebooks/chicago-crimes-analysis/chicago-crimes-analytics.ipynb" = "chicago-crimes-analysis/chicago-crimes-analytics.ipynb",
   
  }
}
resource "google_storage_bucket_object" "upload_notebooks_to_gcs" {
  for_each = var.notebooks_to_upload
  name     = each.value
  source   = "${path.module}/${each.key}"
  bucket   = "${local.lab_notebook_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation
  ]

}

variable "scripts_to_upload" {
  type = map(string)
  default = {
    "../notebooks/chicago-crimes-analysis/chicago-crimes-analytics.ipynb" = "chicago-crimes-analysis/chicago-crimes-analytics.ipynb",
   
  }
}
resource "google_storage_bucket_object" "upload_scripts_to_gcs" {
  for_each = var.scripts_to_upload
  name     = each.value
  source   = "${path.module}/${each.key}"
  bucket   = "${local.lab_notebook_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation
  ]

}
