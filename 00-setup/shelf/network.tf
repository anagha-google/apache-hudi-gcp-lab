/************************************************************************
Create VPC network & subnet
 ***********************************************************************/
module "create_vpc" {
  source                                 = "terraform-google-modules/network/google"
  project_id                             = local.project_id
  network_name                           = local.vpc_nm
  routing_mode                           = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${local.spark_subnet_nm}"
      subnet_ip             = "${local.spark_subnet_cidr}"
      subnet_region         = "${local.location}"
      subnet_range          = local.spark_subnet_cidr
      subnet_private_access = true
    },
    {
      subnet_name           = "${local.catchall_subnet_nm}"
      subnet_ip             = "${local.catchall_subnet_cidr}"
      subnet_region         = "${local.location}"
      subnet_range          = local.catchall_subnet_cidr
      subnet_private_access = true
    },
  ]
  depends_on = [
    time_sleep.sleep_after_identities_permissions
  ]
}

/******************************************
Create Firewall rules 
 *****************************************/

resource "google_compute_firewall" "create_firewall_rule" {
  project   = local.project_id 
  name      = "allow-intra-snet-ingress-to-any"
  network   = local.vpc_nm
  direction = "INGRESS"
  source_ranges = [local.subnet_cidr]
  allow {
    protocol = "all"
  }
  description        = "Creates firewall rule to allow ingress from within subnet on all ports, all protocols"
  depends_on = [
    module.create_vpc
  ]
}



/*******************************************
Introduce sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_creating_network_services" {
  create_duration = "120s"
  depends_on = [
    module.create_vpc,
    google_compute_firewall.create_firewall_rule

  ]
}


