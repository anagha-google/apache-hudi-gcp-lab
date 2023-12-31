

# Module 6c: Column Level Masking powered by BigLake 

This module is a continuation of the prior module and showcases Column Level Masking made possible with BigLake on your Hudi snapshots sitting in Cloud Storage. Details about column masking are available in the [documentation](https://cloud.google.com/bigquery/docs/column-data-masking-intro), the author has provided a one stop shop example for you in this lab module.

<br>

<hr>

## 1. Foundational Security Setup for the lab module

Covered in [Module-06a](Module-06a.md).
<br>

<hr>

## 2. Configuring Column Level Masking (CLM) - on BigLake tables 

### 2.1. CLM setup for the lab
In the previous module, we configured column level security. Lets add masking to the setup we already did. We'll mask the total_amount column to show just 0, for the data engineer ONLY. The rest of the users will see clear-text values.<br><br> For masking to show just 0, the masking rule to be applied is "Default masking value" as detailed in the [documentation](https://cloud.google.com/bigquery/docs/column-data-masking-intro#auth-inheritance). <br>


![README](../04-images/m06c-06.png)   
<br><br>

<br><br>

### 2.2. What's involved

![README](../04-images/m06c-07.png)   
<br><br>

<br>

<hr>

## 3. Lab

### 3.1. [Step 1] Create a Taxonomy

We already created a taxonomy called "BusinessCritical-NYCT" in a [proir module](Module-06b.md), we will reuse the same.

<br>

<hr>

### 3.2. [Step 2] Create a policy tag called "ConfidentialData" under the taxonomy we already created earlier


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

Here is what the Taxonomy looks in the BigQuery UI-

![README](../04-images/m06-24.png)   
<br><br>

<br>

<hr>

### 3.3. [Step 3] Create a (masking) data policy associated with the ConfidentialData policy tag created above

Paste the below in Cloud Shell-
```
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
LOCATION="us-central1"

TAXONOMY="BusinessCritical-NYCT"
TAXONOMY_ID=`gcloud data-catalog taxonomies list --location=$LOCATION | grep -A1 $TAXONOMY | grep taxonomies | cut -d'/' -f6`
CONFIDENTIAL_POLICY_NM="ConfidentialData"
CONFIDENTIAL_POLICY_TAG_ID=`gcloud data-catalog taxonomies policy-tags list --taxonomy=$TAXONOMY_ID --location=$LOCATION | grep -A1 ConfidentialData  | grep policyTags | cut -d'/' -f8`
DATA_POLICY_ID="NYCT_Fare_Masking"

curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "x-goog-user-project: $PROJECT_ID" \
  -H "Content-Type: application/json; charset=utf-8" \
  --data "{\"dataPolicyType\":\"DATA_MASKING_POLICY\",\"dataMaskingPolicy\":{\"predefinedExpression\":\"DEFAULT_MASKING_VALUE\"},\"policyTag\":\"projects/$PROJECT_ID/locations/$LOCATION/taxonomies/$TAXONOMY_ID/policyTags/$CONFIDENTIAL_POLICY_TAG_ID\",\"dataPolicyId\":\"$DATA_POLICY_ID\"}" \
"https://bigquerydatapolicy.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/dataPolicies"
```

Here is the author's output-
```
--THIS IS INFORMATIONAL ONLY--
{
  "name": "projects/apache-hudi-lab/locations/us-central1/dataPolicies/NYCT_Fare_Masking",
  "dataPolicyType": "DATA_MASKING_POLICY",
  "dataPolicyId": "NYCT_Fare_Masking",
  "policyTag": "projects/apache-hudi-lab/locations/us-central1/taxonomies/2067815749752692148/policyTags/4607361211901247622",
  "dataMaskingPolicy": {
    "predefinedExpression": "DEFAULT_MASKING_VALUE"
  }
}

```

Here is what the Taxonomy looks in the BigQuery UI after adding the masking data policy to the policy tag-

![README](../04-images/m06c-01.png)   
<br><br>

<br>

<hr>


### 3.4. [Step 4] Update the BigLake table schema file to associate the policy tag, "ConfidentialData" with the "total_amount" column in the BigLake table

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

Author's sample-
```
This is informational ONLY-

[
  {
    "mode": "NULLABLE",
    "name": "_hoodie_commit_time",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "_hoodie_commit_seqno",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "_hoodie_record_key",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "_hoodie_partition_path",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "_hoodie_file_name",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "taxi_type",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "trip_hour",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "trip_minute",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "vendor_id",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "pickup_datetime",
    "type": "TIMESTAMP"
  },
  {
    "mode": "NULLABLE",
    "name": "dropoff_datetime",
    "type": "TIMESTAMP"
  },
  {
    "mode": "NULLABLE",
    "name": "store_and_forward",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "rate_code",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "pickup_location_id",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "dropoff_location_id",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "passenger_count",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "trip_distance",
    "type": "NUMERIC"
  },
  {
    "mode": "NULLABLE",
    "name": "fare_amount",
    "type": "NUMERIC",
    "policyTags": {
      "names": [
        "projects/apache-hudi-lab/locations/us-central1/taxonomies/2067815749752692148/policyTags/3588092525560622523"
      ]
    }
  },
  {
    "mode": "NULLABLE",
    "name": "surcharge",
    "type": "NUMERIC"
  },
  {
    "mode": "NULLABLE",
    "name": "mta_tax",
    "type": "NUMERIC"
  },
  {
    "mode": "NULLABLE",
    "name": "tip_amount",
    "type": "NUMERIC",
    "policyTags": {
      "names": [
        "projects/apache-hudi-lab/locations/us-central1/taxonomies/2067815749752692148/policyTags/3588092525560622523"
      ]
    }
  },
  {
    "mode": "NULLABLE",
    "name": "tolls_amount",
    "type": "NUMERIC"
  },
  {
    "mode": "NULLABLE",
    "name": "improvement_surcharge",
    "type": "NUMERIC"
  },
  {
    "mode": "NULLABLE",
    "name": "total_amount",
    "type": "NUMERIC",
    --------------WHAT WE STARTS HERE------------------------------------------------------------------------------
    "policyTags": {
      "names": [
        "projects/apache-hudi-lab/locations/us-central1/taxonomies/2067815749752692148/policyTags/4607361211901247622"
      ]
    }
    --------------ENDS HERE------------------------------------------------------------------------------
  },
  {
    "mode": "NULLABLE",
    "name": "payment_type_code",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "congestion_surcharge",
    "type": "NUMERIC"
  },
  {
    "mode": "NULLABLE",
    "name": "trip_type",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "ehail_fee",
    "type": "NUMERIC"
  },
  {
    "mode": "NULLABLE",
    "name": "partition_date",
    "type": "DATE"
  },
  {
    "mode": "NULLABLE",
    "name": "distance_between_service",
    "type": "NUMERIC"
  },
  {
    "mode": "NULLABLE",
    "name": "time_between_service",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "trip_year",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "trip_month",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "trip_day",
    "type": "STRING"
  }
]
```

<hr>

### 3.5. [Step 5] Update the BigLake table with the schema file 

Run the below in Cloud Shell-
```
bq update \
   $PROJECT_ID:gaia_product_ds.nyc_taxi_trips_hudi_biglake ~/nyc_taxi_trips_hudi_biglake_schema.json
```

<br>

![README](../04-images/m06-25.png)   
<br><br>

<br>

<hr>

### 3.6. [Step 6] Grant the taxi marketing managers fine grained reader and clear-text access to column that is policy tagged as "ConfidentialData"

Run this in Cloud Shell, after editing the command to reflect your user specific emails:
```
YELLOW_TAXI_USER_EMAIL="--REPLACE with YOUR_YELLOW_TAXI_DUDETTE_EMAIL--"
GREEN_TAXI_USER_EMAIL="--REPLACE with YOUR_GREEN_TAXI_DUDE_EMAIL--"

TAXONOMY="BusinessCritical-NYCT"
TAXONOMY_ID=`gcloud data-catalog taxonomies list --location=$LOCATION | grep -A1 $TAXONOMY | grep taxonomies | cut -d'/' -f6`
CONFIDENTIAL_POLICY_NM="ConfidentialData"
CONFIDENTIAL_POLICY_TAG_ID=`gcloud data-catalog taxonomies policy-tags list --taxonomy=$TAXONOMY_ID --location=$LOCATION | grep -A1 ConfidentialData  | grep policyTags | cut -d'/' -f8`

curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "x-goog-user-project: $PROJECT_ID" \
    -H "Content-Type: application/json; charset=utf-8" \
  https://datacatalog.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/taxonomies/$TAXONOMY_ID/policyTags/${CONFIDENTIAL_POLICY_TAG_ID}:setIamPolicy -d  "{\"policy\":{\"bindings\":[{\"role\":\"roles/datacatalog.categoryFineGrainedReader\",\"members\":[\"user:$YELLOW_TAXI_USER_EMAIL\",\"user:$GREEN_TAXI_USER_EMAIL\"]}]}}"

```


Author's output:
```
INFORMATIONAL-DO NOT RUN THIS-
{
  "version": 1,
  "etag": "BwYA2apTSco=",
  "bindings": [
    {
      "role": "roles/datacatalog.categoryFineGrainedReader",
      "members": [
        "user:green-taxi-marketing-mgr@akhanolkar.altostrat.com",
        "user:yellow-taxi-marketing-mgr@akhanolkar.altostrat.com"
      ]
    }
  ]
}
```

Here is what the ACLs look like in the UI-

![README](../04-images/m06c-03.png)   
<br><br>


<br>



<hr>


### 3.7. [Step 7] Grant the data engineer (data) masked access (replace with 0) to the column that is policy tagged as "ConfidentialData"

Paste the below in Cloud Shell-
```
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
LOCATION="us-central1"
DATA_POLICY_ID="NYCT_Fare_Masking"
DATA_ENGINEER_USER_EMAIL="REPLACE WITH YOUR DATA ENGINEER EMAIL"

curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "x-goog-user-project: $PROJECT_ID" \
  -H "Content-Type: application/json; charset=utf-8" \
  --data "{\"policy\":{\"bindings\":[{\"members\":[\"user:$DATA_ENGINEER_USER_EMAIL\"],\"role\":\"roles/bigquerydatapolicy.maskedReader\"}]}}" \
 "https://bigquerydatapolicy.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/dataPolicies/$DATA_POLICY_ID:setIamPolicy" 
```

Author's output:
```
INFORMATIONAL-DO NOT RUN THIS-
{
  "version": 1,
  "etag": "BwYA2aDzLak=",
  "bindings": [
    {
      "role": "roles/bigquerydatapolicy.maskedReader",
      "members": [
        "user:data-engineer@akhanolkar.altostrat.com"
      ]
    }
  ]
}
```

<br>

<hr>

## 4. Column Level Masking in action in BigLake table on Hudi snapshot from the BigQuery UI

Recap:<br>
Here is the Column Level Masking configuration we applied in this lab module.

### 4.1. Sign-in to the BigQuery UI as the Yellow Taxi user & query the table from the BigQuery UI

Paste in the BigQuery UI:
```
SELECT total_amount,* FROM `apache-hudi-lab.gaia_product_ds.nyc_taxi_trips_hudi_biglake` WHERE TRIP_YEAR='2019' AND trip_month='4' AND trip_day='23'  
AND pickup_location_id='161' AND dropoff_location_id='239' AND TRIP_HOUR IN (20,19) AND VENDOR_ID='1' AND TRIP_DISTANCE IN (3.1, 3.2)
```

Here is a visual of the results expected:


![README](../04-images/m06c-04.png)   
<br><br>

<br>

<hr>

### 4.2. Sign-in to the BigQuery UI as the Green Taxi user & query the table from the BigQuery UI

Paste in the BigQuery UI, the same query as #4.1 and you should see the similar results with green taxi trips.

<br>

<hr>

### 4.3. Sign-in to the BigQuery UI as the Data Engineer user & query the table from the BigQuery UI

Paste the same SQL as 4.1, in the BigQuery UI:
```
SELECT total_amount,* FROM `apache-hudi-lab.gaia_product_ds.nyc_taxi_trips_hudi_biglake` WHERE TRIP_YEAR='2019' AND trip_month='4' AND trip_day='23'  
AND pickup_location_id='161' AND dropoff_location_id='239' AND TRIP_HOUR IN (20,19) AND VENDOR_ID='1' AND TRIP_DISTANCE IN (3.1, 3.2)
```

Here is a visual of the results expected - the total fare amount is replaced with 0, from the "DEFAULT_MASKING_VALUE" of the data masking policy applied:

![README](../04-images/m06c-05.png)   
<br><br>

<hr>

This concludes the module, proceed to the [next module](Module-07.md).




