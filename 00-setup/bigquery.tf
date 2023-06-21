resource "google_bigquery_dataset" "bq_raw_dataset_creation" {
  dataset_id                  = local.bq_raw_dataset
  location                    = local.location
  depends_on = [time_sleep.sleep_after_identities_permissions]
}

resource "google_bigquery_dataset" "bq_curated_dataset_creation" {
  dataset_id                  = local.bq_curated_dataset
  location                    = local.location
  depends_on = [time_sleep.sleep_after_identities_permissions]
}

resource "google_bigquery_dataset" "bq_product_dataset_creation" {
  dataset_id                  = local.bq_product_dataset
  location                    = local.location
  depends_on = [time_sleep.sleep_after_identities_permissions]
}

resource "google_bigquery_connection" "bq_external_connection_creation" {
    connection_id = local.bq_connection
    project = var.project_id
    location = local.location
    cloud_resource {}
    depends_on = [time_sleep.sleep_after_identities_permissions]
} 

resource "google_project_iam_member" "bq_connection_gmsa_iam_role_grant" {
    project = var.project_id
    role = "roles/storage.objectViewer"
    member = format("serviceAccount:%s", google_bigquery_connection.bq_external_connection_creation.cloud_resource[0].service_account_id)

    depends_on = [google_bigquery_connection.bq_external_connection_creation]

}


resource "time_sleep" "sleep_after_bq_objects_creation" {
  create_duration = "60s"
  depends_on = [
    google_bigquery_dataset.bq_raw_dataset_creation,
    google_bigquery_dataset.bq_curated_dataset_creation,
    google_bigquery_dataset.bq_product_dataset_creation,
    google_bigquery_connection.bq_external_connection_creation,
    google_project_iam_member.bq_connection_gmsa_iam_role_grant

  ]
}
