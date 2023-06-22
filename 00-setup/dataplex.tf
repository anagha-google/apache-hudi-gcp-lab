resource "google_dataplex_lake" "create_lake" {
 for_each = {
    "${local.lake_nm}/Data Lake" : "owner=${local.resource_prefix}",
  }
  location     = local.location
  name         = element(split("/", each.key), 0)
  description  = element(split("/", each.key), 1)
  display_name = element(split("/", each.key), 1)

  labels       = {
    element(split("=", each.value), 0) = element(split("=", each.value), 1)
  }
  
  project = local.project_id
  depends_on = [time_sleep.sleep_after_creating_dpgce]
}

resource "time_sleep" "sleep_after_lake_creation" {
  create_duration = "120s"
  depends_on = [google_dataplex_lake.create_lake]
}


resource "google_dataplex_zone" "create_zones" {
 for_each = {
    "${local.resource_prefix}-raw-zone/Raw Zone/RAW" : ""
    "${local.resource_prefix}-curated-zone/Curated Zone/CURATED" : ""
    "${local.resource_prefix}-product-zone/Product Zone/CURATED" : ""
  }

  project      = var.project_id
  lake         =  local.lake_nm
  location     =  local.location
  name         = element(split("/", each.key), 0)
  description  = element(split("/", each.key), 1)
  display_name = element(split("/", each.key), 1)
  type         = element(split("/", each.key), 2)

  discovery_spec {
    enabled = true
    schedule = "0 * * * *"
  }

  resource_spec {
    location_type = "SINGLE_REGION"
  }

  depends_on  = [time_sleep.sleep_after_lake_creation]
}

resource "time_sleep" "sleep_after_dataplex_deployments" {
  create_duration = "120s"
  depends_on = [google_dataplex_lake.create_zones]
}
