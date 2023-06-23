# Module 1: Setup foundations

In this module, you will get started with Terraform. We will enable requisite Google APIs and optionally update Organization policies. 

1. You will create a project manually
2. Clone the lab Git repo
3. Configure your preferences for the lab
4. Run Terraform init
5. Run Terraform plan and review the same
6. Run Terraform apply and watch for completion

   
**Lab Module Duration:** <br>
5 minutes 

**Prerequisite:** <br>
Create a new project manually for this lab. 

## 1. Clone the repo
Run this on Cloud Shell scoped to the new project you created for the lab.
```
cd ~
git clone https://github.com/anagha-google/apache-hudi-gcp-lab.git
cd apache-hudi-gcp-lab
```

<hr>

## 2. Familiarize yourself with the layout

```
THIS IS FYI - DO NOT EXECUTE
~/apache-hudi-gcp-lab
         00-setup
         01-scripts
         02-notebooks
         03-lab-guide
         README.md
```
Explore the repo really quick.

## 3. Layout of the Terraform root directory
```
THIS IS FYI - DO NOT EXECUTE
~/apache-hudi-gcp-lab/00-setup
           
├── bash.tf
├── bigquery.tf
├── composer.tf
├── configure-preferences.sh <--- We will first run this
├── dataplex.tf
├── dpgce.tf
├── dpms.tf
├── iam.tf
├── main.tf
├── module_apis_and_policies <--- And then run terraform apply in this directory to enable Google APIs and update Org policies
│   ├── main.tf
│   └── variables.tf
├── network.tf
├── output.tf
├── phs.tf
├── storage.tf
├── variables.tf
└── versions.tf
           
```

## 3. Configure your preferences in the preferences script

Edit the file configure.sh under 00-setup for your preferences.<br>
E.g. 
1. Update the GCP region and zone to match your preference.<br>
2. Update the Dataproc version as needed.<br>
3. Update the Cloud Composer version as needed.<br>

If you are okay with provisioning as designed by the author, skip the step of editing and move to step 4.

```
cd ~/apache-hudi-gcp-lab/00-setup
vi configure-preferences.sh
```

## 4. Run the preferences shell script



4.1. Run the command below in Cloud shell-
```
cd ~/apache-hudi-gcp-lab/00-setup
./configure-preferences.sh
```

4.2. This creates a variables file called terraform.tfvars that will be used for the rest of the lab. Lets review the file.<br>
Run the command below in Cloud shell-
```
cat ~/apache-hudi-gcp-lab/00-setup/terraform.tfvars
```

Here is the author's output-
```
project_id = "apache-hudi-lab"
project_number = "3437xx791"
project_name = "apache-hudi-lab"
gcp_account_name = "xxx@google.com"
org_id = "2365xxxx571"
dataproc_gce_image_version = "2.1.14-debian11"
cloud_composer_image_version = "composer‑2.3.1‑airflow‑2.5.1"
gcp_region = "us-central1"
gcp_zone = "us-central1-a"
gcp_multi_region = "US"
provision_vertex_ai_bool = "false"
update_org_policies_bool = "true"

```

**Note:** <br>
The boolean for updating the org policies is in the terraform.tfvars. Google Customer engineers **need to** update org policies (default=true) in their designated environments, but this is not applicable for everyone. Set the boolean to false in the tfvars file if you dont need to org policies in your environment.<br>

<hr>

## 5. Initialize Terraform

5.1. Run the init command in Cloud Shell-
```
cd ~/apache-hudi-gcp-lab/00-setup/
terraform init
```
You will see some output in the console. <br>

5.2. Check the directory to see what got created there.

```
cd ~/apache-hudi-gcp-lab/00-setup/
ls -al
```

Author's output is-
```
-rwxr-xr-x  1 admin_ admin_ 1645 Oct 24 16:37 configure-preferences.sh
-rw-r--r--  1 admin_ admin_ 2869 Oct 24 16:19 main.tf
drwxr-xr-x  2 admin_ admin_ 4096 Oct 24 16:08 module_apis_and_policies
drwxr-xr-x  4 admin_ admin_ 4096 Oct 24 16:49 **.terraform**
-rw-r--r--  1 admin_ admin_ 3335 Oct 24 16:49 **.terraform.lock.hcl**
-rw-r--r--  1 admin_ admin_  460 Oct 24 16:38 terraform.tfvars
-rw-r--r--  1 admin_ admin_  876 Oct 24 16:20 variables.tf
-rw-r--r--  1 admin_ admin_  263 Oct 24 15:06 versions.tf
```

<hr>

## 6. Review the Terraform execution plan

Terraform Hashicorp Configuration Language (HCL) is declarative (and not imperative). When you run the plan, it studies the configuration and comes up with an execution plan. Review the plan in Cloud Shell.

```
cd ~/apache-hudi-gcp-lab/00-setup/
terraform plan
```

Study the output and see the number of resources that will be provisioned.

## 7. Execute Terraform apply

```
This is informational - DO NOT RUN THIS

├── bash.tf
├── bigquery.tf
├── composer.tf
├── configure-preferences.sh
├── dataplex.tf
├── dpgce.tf
├── dpms.tf
├── iam.tf
├── main.tf
├── module_apis_and_policies
│   ├── main.tf                             <--- We will run this
│   └── variables.tf
├── network.tf
├── output.tf
├── phs.tf
├── storage.tf
├── variables.tf
└── versions.tf

```



<hr> 

This concludes the module, proceed to the [next module](Module-02.md).

<hr>