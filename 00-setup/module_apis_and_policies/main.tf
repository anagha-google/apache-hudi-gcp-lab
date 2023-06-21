/******************************************
1. Enable Google APIs in parallel
 *****************************************/
module "activate_google_apis" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  project_id                  = var.project_id
  enable_apis                 = true
  disable_services_on_destroy = false

  activate_apis = [
    "dataproc.googleapis.com",
    "metastore.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "bigquery.googleapis.com", 
    "storage.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "bigquerydatapolicy.googleapis.com",
    "storage-component.googleapis.com",
    "bigquerystorage.googleapis.com",
    "datacatalog.googleapis.com",
    "dataplex.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudidentity.googleapis.com",
    "composer.googleapis.com",
    "metastore.googleapis.com",
    "orgpolicy.googleapis.com",
    "dlp.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "datapipelines.googleapis.com",
    "cloudscheduler.googleapis.com",
    "datalineage.googleapis.com"
  ]  
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_api_enabling" {
  create_duration = "180s"
  depends_on = [
   module.activate_google_apis
  ]
}

/******************************************
2. Update organization policies in parallel
 *****************************************/

resource "google_project_organization_policy" "orgPolicyUpdate_disableSerialPortLogging" {
  count = var.update_org_policies_bool ? 1 : 0
  project     = var.project_id
  constraint = "compute.disableSerialPortLogging"
  boolean_policy {
    enforced = false
  }
}

resource "google_project_organization_policy" "orgPolicyUpdate_requireOsLogin" {
  count = var.update_org_policies_bool ? 1 : 0
  project     = var.project_id
  constraint = "compute.requireOsLogin"
  boolean_policy {
    enforced = false
  }
}

resource "google_project_organization_policy" "orgPolicyUpdate_requireShieldedVm" {
  count = var.update_org_policies_bool ? 1 : 0
  project     = var.project_id
  constraint = "compute.requireShieldedVm"
  boolean_policy {
    enforced = false
  }
}

resource "google_project_organization_policy" "orgPolicyUpdate_vmCanIpForward" {
  count = var.update_org_policies_bool ? 1 : 0
  project     = var.project_id
  constraint = "compute.vmCanIpForward"
  list_policy {
    allow {
      all = true
    }
  }
}

resource "google_project_organization_policy" "orgPolicyUpdate_vmExternalIpAccess" {
  count = var.update_org_policies_bool ? 1 : 0
  project     = var.project_id
  constraint = "compute.vmExternalIpAccess"
  list_policy {
    allow {
      all = true
    }
  }
}

resource "google_project_organization_policy" "orgPolicyUpdate_restrictVpcPeering" {
  count = var.update_org_policies_bool ? 1 : 0
  project     = var.project_id
  constraint = "compute.restrictVpcPeering"
  list_policy {
    allow {
      all = true
    }
  }
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_org_policy_updates" {
  create_duration = "120s"
  depends_on = [
    google_project_organization_policy.orgPolicyUpdate_disableSerialPortLogging,
    google_project_organization_policy.orgPolicyUpdate_requireOsLogin,
    google_project_organization_policy.orgPolicyUpdate_requireShieldedVm,
    google_project_organization_policy.orgPolicyUpdate_vmCanIpForward,
    google_project_organization_policy.orgPolicyUpdate_vmExternalIpAccess,
    google_project_organization_policy.orgPolicyUpdate_restrictVpcPeering
  ]
}

