/******************************************
Output important variables needed for the demo
******************************************/

output "PROJECT_ID" {
  value = local.project_id
}

output "PROJECT_NBR" {
  value = local.project_nbr
}

output "LOCATION" {
  value = local.location
}

output "VPC_NM" {
  value = local.vpc_nm
}

output "SPARK_SUBNET" {
  value = local.spark_subnet_nm
}

output "CATCHALL_SUBNET" {
  value = local.catchall_subnet_nm
}

output "PERSISTENT_HISTORY_SERVER_NM" 
  value = local.phs_nm
}

output "DPMS_NM" {
  value = local.dpms_nm
}

output "UMSA_FQN" {
  value = local.umsa_fqn
}

output "DATA_BUCKET" {
  value = local.data_bucket
}

output "CODE_BUCKET" {
  value = local.code_bucket
}

output "NOTEBOOK_BUCKET" {
  value = local.notebook_bucket
}

