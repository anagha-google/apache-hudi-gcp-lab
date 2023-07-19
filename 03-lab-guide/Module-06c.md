

# Module 6c: Column Level Masking powered by BigLake 

This module is a continuation of the prior module and showcases Column Level Masking made possible with BigLake on your Hudi snapshots sitting in Cloud Storage. 

<hr>

## 1. Foundational Security Setup for the lab module

Covered in [Module 6a](Module-06a.md).
<hr>



## 2. Configuring Column Level Masking (CLM) - on BigLake tables 

### 2.1. CLM setup for the lab
Lets add masking to the setup we already did-

| User  |  Column Access | Access type | 
| :-- | :--- | :--- |
| yellow-taxi-marketing-mgr | All columns | Clear-text |
| green-taxi-marketing-mgr | All columns | Clear-text |
| data-engineer |  All columns except fare, tips & total amount | Masking of total_amount column |

<br><br>

### 2.2. What's involved

<br><br>


## 3. Lab

### 3.1. [Step 2] Create a policy tag called "ConfidentialData" under the taxonomy we already created earlier
(Step 1 is creating a Taxonomy which we already did earlier in this lab module)<br><br>

Run this in Cloud Shell-
```
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
LOCATION="us-central1"

TAXONOMY="BusinessCritical-NYCT"
TAXONOMY_ID=`gcloud data-catalog taxonomies list --location=$LOCATION | grep -A1 $TAXONOMY | grep taxonomies | cut -d'/' -f6`
CONFIDENTIAL_POLICY_NM="ConfidentialData"

rm -rf ~/requestPolicyTagCreate.json
echo "{ \"displayName\": \"$CONFIDENTIAL_POLICY_NM\" }" >>  requestPolicyTagCreate.json

curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "x-goog-user-project: $PROJECT_ID" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d @requestPolicyTagCreate.json \
    "https://datacatalog.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/taxonomies/$TAXONOMY_ID/policyTags"

```

Sample output of author-
```
INFORMATIONAL ONLY - DONT RUN THIS
{
  "name": "projects/apache-hudi-lab/locations/us-central1/taxonomies/2067815749752692148/policyTags/4607361211901247622",
  "displayName": "ConfidentialData"
}
```

Lets grab the Confidential Policy Tag ID for the next step:
```
CONFIDENTIAL_POLICY_TAG_ID=`gcloud data-catalog taxonomies policy-tags list --taxonomy=$TAXONOMY_ID --location=$LOCATION | grep -A1 ConfidentialData  | grep policyTags | cut -d'/' -f8`
```

![README](../04-images/m06-24.png)   
<br><br>

<br><br>


### 3.2. [Step 3] Update the BigLake table schema file to include/associate the policy tag, "ConfidentialData" with the "total_amount" column in the BigLake table

We have a file locally already, that we created that has the schema of the BigLake table with the updates we made for the FinancialData policy tag. Lets add the ConfidentialData policy tag to the total_amount column. 

```
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
LOCATION="us-central1"

TAXONOMY="BusinessCritical-NYCT"
TAXONOMY_ID=`gcloud data-catalog taxonomies list --location=$LOCATION | grep -A1 $TAXONOMY | grep taxonomies | cut -d'/' -f6`
CONFIDENTIAL_POLICY_TAG_ID=`gcloud data-catalog taxonomies policy-tags list --taxonomy=$TAXONOMY_ID --location=$LOCATION | grep -A1 ConfidentialData  | grep policyTags | cut -d'/' -f8`

# Policy tag spec to insert into the schema file
POLICY_TAG_SPEC="    ,\"policyTags\": {\"names\": [\"projects/$PROJECT_ID/locations/$LOCATION/taxonomies/$TAXONOMY_ID/policyTags/$CONFIDENTIAL_POLICY_TAG_ID\"]}"

cd ~
# Copy the schema json
cp nyc_taxi_trips_hudi_biglake_schema.json dummy.json
# Insert policy tag into it
sed -i "126 a $POLICY_TAG_SPEC" dummy.json
# Format it
(rm -f nyc_taxi_trips_hudi_biglake_schema.json && cat dummy.json | jq . > nyc_taxi_trips_hudi_biglake_schema.json) < nyc_taxi_trips_hudi_biglake_schema.json
# Remove the dummy.json
rm dummy.json
```

<br><br>

### 3.3. [Step 4] Update the BigLake table with the schema file 

Run the below in Cloud Shell-
```
bq update \
   $PROJECT_ID:gaia_product_ds.nyc_taxi_trips_hudi_biglake ~/nyc_taxi_trips_hudi_biglake_schema.json
```

<br>

![README](../04-images/m06-25.png)   
<br><br>

<br><br>

### 3.4. [Step 5] Assign the policy to the taxi marketing managers to allow access to confidential data

Run this in Cloud Shell, after editing the command to reflect your user specific emails:
```
DATA_ENGINEER_USER_EMAIL="data-engineer@akhanolkar.altostrat.com"

PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
LOCATION="us-central1"

TAXONOMY="BusinessCritical-NYCT"
TAXONOMY_ID=`gcloud data-catalog taxonomies list --location=$LOCATION | grep -A1 $TAXONOMY | grep taxonomies | cut -d'/' -f6`
CONFIDENTIAL_POLICY_TAG_ID=`gcloud data-catalog taxonomies policy-tags list --taxonomy=$TAXONOMY_ID --location=$LOCATION | grep -A1 ConfidentialData  | grep policyTags | cut -d'/' -f8`


curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "x-goog-user-project: $PROJECT_ID" \
    -H "Content-Type: application/json; charset=utf-8" \
  https://datacatalog.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/taxonomies/$TAXONOMY_ID/policyTags/${CONFIDENTIAL_POLICY_TAG_ID}:setIamPolicy -d  "{\"policy\":{\"bindings\":[{\"role\":\"roles/bigquerydatapolicy.maskedReader\",\"members\":[\"user:$DATA_ENGINEER_USER_EMAIL\"]}]}}"

```


Author's output:
```
INFORMATIONAL-DO NOT RUN THIS-

```

<br>

<hr>


