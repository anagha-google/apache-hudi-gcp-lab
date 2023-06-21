/******************************************
Run bash scripts
 *****************************************/

resource "null_resource" "run_bash_script" {
    provisioner "local-exec" {

        command = "/bin/bash ../02-scripts/bash/run_service_updates.sh ${local.admin_upn_fqn} ${local.location} "
    }
    depends_on = [
        time_sleep.sleep_after_network_and_storage_steps
        google_dataproc_metastore_service.datalake_metastore_creation
    ]
}

