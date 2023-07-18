
# Module 6: Fine Grained Access Control powered by BigLake 

This module showcases Row Level Security, Column Level Security (access control and data masking) made possible with BigLake on your Hudi snapshots sitting in Cloud Storage. 

<hr>

## 1. Foundational Security Setup for the lab module

We will create three IAM groups and three users belonging to them.
<br>

### 1.1. Create IAM groups

Create three IAM groups, similar to below from admin.google.com.

![README](../04-images/m06-01.png)   
<br><br>

### 1.2. Create IAM users belonging to the three groups

Create three IAM users, and add them to the groups created above, as shown below.

![README](../04-images/m06-02.png)   
<br><br>

<hr>

## 2. Configuring Row Level Security (RLS) on BigLake tables

### 2.1. What's involved

![README](../04-images/m06-12.png)   
<br><br>

### 2.2. RLS security setup for the lab

We will create row level policies that allow yellow and green taxi marketing groups access to taxi trip data for the respective taxi type data (yellow taxi/green taxi). The tech stop team gets access to all taxi types.

![README](../04-images/m06-03.png)   
<br><br>

### 2.3. Create a RLS policy for Yellow Taxi data

In the sample below, the author is granting the groups, nyc-yellow-taxi-marketing@ and nyc-taxi-tech-stop@ access to yellow taxi data. <br>

Run the command below, after updating with your IAM groups, in the BigQuery UI-
```
CREATE OR REPLACE ROW ACCESS POLICY yellow_taxi_rap
ON gaia_product_ds.nyc_taxi_trips_hudi_biglake
GRANT TO ("group:YOUR_YELLOW_TAXI_IAM_GROUP", "group:YOUR_TECH_STOP_IAM_GROUP")
FILTER USING (taxi_type = "yellow");
```

Here is the author's command-
```
---THIS IS FYI only--------------------------------
CREATE OR REPLACE ROW ACCESS POLICY yellow_taxi_rap
ON gaia_product_ds.nyc_taxi_trips_hudi_biglake
GRANT TO ("group:nyc-yellow-taxi-marketing@akhanolkar.altostrat.com","group:nyc-taxi-tech-stop@akhanolkar.altostrat.com")
FILTER USING (taxi_type = "yellow");
```

![README](../04-images/m06-05.png)   
<br><br>


### 2.4. Create a RLS policy for Green Taxi data

In the sample below, the author is granting the groups, nyc-green-taxi-marketing@ and nyc-taxi-tech-stop@ access to green taxi data. <br>

Run the command below, after updating with your IAM groups, in the BigQuery UI-
```
CREATE OR REPLACE ROW ACCESS POLICY green_taxi_rap
ON gaia_product_ds.nyc_taxi_trips_hudi_biglake
GRANT TO ("group:YOUR_GREEN_TAXI_IAM_GROUP", "group:YOUR_TECH_STOP_IAM_GROUP")
FILTER USING (taxi_type = "green");
```

Here is the author's command-
```
---THIS IS FYI only--------------------------------
CREATE OR REPLACE ROW ACCESS POLICY green_taxi_rap
ON gaia_product_ds.nyc_taxi_trips_hudi_biglake
GRANT TO ("group:nyc-green-taxi-marketing@akhanolkar.altostrat.com","group:nyc-taxi-tech-stop@akhanolkar.altostrat.com")
FILTER USING (taxi_type = "green");
```
![README](../04-images/m06-06.png)   
<br><br>

### 2.5. View the RLS policies configured from the BigQuery UI

Navigate to the RLS policies as shown below-

![README](../04-images/m06-04.png)   
<br><br>

![README](../04-images/m06-07.png)   
<br><br>

![README](../04-images/m06-08.png)   
<br><br>

### 2.6. Managing RLS on BigLake tables

[Documentation](https://cloud.google.com/bigquery/docs/managing-row-level-security)

<br><br>

<hr>

## 3. Configuring Column Level Security (CLS) on BigLake tables

### 3.1. What's involved

![README](../04-images/m06-13.png)   
<br><br>

![README](../04-images/m06-13a.png)   
<br><br>

<br><br>

### 3.2. [Step 1] Create a taxonomy called "BusinessCritical-NYCT"

Run this in Cloud Shell-
```
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
LOCATION="us-central1"
TAXONOMY="BusinessCritical-NYCT"

rm -rf requestTaxonomyCreate.json
echo "{ \"displayName\": \"BusinessCritical-NYCT\" }" >>  requestTaxonomyCreate.json

curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "x-goog-user-project: $PROJECT_ID" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d @requestTaxonomyCreate.json \
    "https://datacatalog.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/taxonomies"

```

Sample output of author-
```
INFORMATIONAL ONLY - DONT RUN THIS
{
  "name": "projects/apache-hudi-lab/locations/us-central1/taxonomies/2067815749752692148",
  "displayName": "BusinessCritical-NYCT",
  "taxonomyTimestamps": {
    "createTime": "2023-07-14T03:20:13.094Z",
    "updateTime": "2023-07-14T03:20:13.094Z"
  },
  "service": {}
}
```

Lets grab the Taxonomy ID for the next step:
```
TAXONOMY_ID=`gcloud data-catalog taxonomies list --location=$LOCATION | grep -A1 $TAXONOMY | grep taxonomies | cut -d'/' -f6`
```

![README](../04-images/m06-09.png)   
<br><br>


![README](../04-images/m06-10.png)   
<br><br>

<br><br>

### 3.3. [Step 2] Create a policy tag called "FinancialData" under the taxonomy

Run this in Cloud Shell-
```

FINANCIAL_POLICY="FinancialData"

rm -rf requestPolicyTagCreate.json
echo "{ \"displayName\": \"$FINANCIAL_POLICY\" }" >>  requestPolicyTagCreate.json

curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "x-goog-user-project: $PROJECT_ID" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d @requestPolicyTagCreate.json \
    "https://datacatalog.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/taxonomies/$TAXONOMY_ID/policyTags"

```

Sample output of author-
```
INFORMATIONAL ONLY - DONT RUN THIS
{
  "name": "projects/apache-hudi-lab/locations/us-central1/taxonomies/2067815749752692148/policyTags/3588092525560622523",
  "displayName": "FinancialData"
}
```

Lets grab the Policy Tag ID for the next step:
```
FINANCIAL_POLICY_TAG_ID=`gcloud data-catalog taxonomies policy-tags list --taxonomy=$TAXONOMY_ID --location=$LOCATION | grep policyTags | cut -d'/' -f8`
```

![README](../04-images/m06-11.png)   
<br><br>

<br><br>

### 3.4. [Step 3] Associate the policy with specific columns in the BigLake table

#### 3.4.1. Create a schema file locally with the policy tag assigned to fare_amount and tip_amount

In Cloud Shell, paste the following into a file called nyc_taxi_trips_hudi_biglake_schema.json in your root directory-
```
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
      "names": ["projects/YOUR_PROJECT_ID/locations/YOUR_BQ_LOCATION/taxonomies/YOUR_TAXONOMY_ID/policyTags/YOUR_POLICY_TAG_ID"]
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
      "names": ["projects/YOUR_PROJECT_ID/locations/YOUR_BQ_LOCATION/taxonomies/YOUR_TAXONOMY_ID/policyTags/YOUR_POLICY_TAG_ID"]
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
    "type": "NUMERIC"
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

<br><br>

#### 3.4.2. Update the schema file with your variables

Paste in Cloud Shell-
```
# Variables
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
LOCATION="us-central1"
TAXONOMY="BusinessCritical-NYCT"
FINANCIAL_POLICY="FinancialData"

# Capture IDs
TAXONOMY_ID=`gcloud data-catalog taxonomies list --location=$LOCATION | grep -A1 $TAXONOMY | grep taxonomies | cut -d'/' -f6`
FINANCIAL_POLICY_TAG_ID=`gcloud data-catalog taxonomies policy-tags list --taxonomy=$TAXONOMY_ID --location=$LOCATION | grep policyTags | cut -d'/' -f8`

echo "Taxonomy ID is $TAXONOMY_ID"
echo "Financial Policy Tag ID is $FINANCIAL_POLICY_TAG_ID"

# Substitute the variables in the schema file
sed -i s/YOUR_PROJECT_ID/$PROJECT_ID/g ~/nyc_taxi_trips_hudi_biglake_schema.json
sed -i s/YOUR_BQ_LOCATION/$LOCATION/g ~/nyc_taxi_trips_hudi_biglake_schema.json
sed -i s/YOUR_TAXONOMY_ID/$TAXONOMY_ID/g ~/nyc_taxi_trips_hudi_biglake_schema.json
sed -i s/YOUR_POLICY_TAG_ID/$FINANCIAL_POLICY_TAG_ID/g ~/nyc_taxi_trips_hudi_biglake_schema.json
```

Once you execute these commands, your schema file should have your values in them instead of the placeholders.


<br><br>


#### 3.4.3. Update the Biglake table schema with the file

Run the below in Cloud Shell-
```
bq update \
   $PROJECT_ID:gaia_product_ds.nyc_taxi_trips_hudi_biglake ~/nyc_taxi_trips_hudi_biglake_schema.json
```

<br><br>


#### 3.4.4. Validate the table update in the BigQuery UI


![README](../04-images/m06-14.png)   
<br><br>

<br><br>


### 3.5. [Step 4] Assign the policy to the taxi marketing managers to allow access to financials

Run this in Cloud Shell, after editing the command to reflect your user specific emails:
```
YELLOW_TAXI_USER_EMAIL="PASTE_EMAIL_HERE"
GREEN_TAXI_USER_EMAIL="PASTE_EMAIL_HERE"

curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "x-goog-user-project: $PROJECT_ID" \
    -H "Content-Type: application/json; charset=utf-8" \
  https://datacatalog.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/taxonomies/$TAXONOMY_ID/policyTags/${FINANCIAL_POLICY_TAG_ID}:setIamPolicy -d  "{\"policy\":{\"bindings\":[{\"role\":\"roles/datacatalog.categoryFineGrainedReader\",\"members\":[\"user:$YELLOW_TAXI_USER_EMAIL\",\"user:$GREEN_TAXI_USER_EMAIL\" ]}]}}"
```

Author's output:
```
INFORMATIONAL-
{
  "version": 1,
  "etag": "BwYAurecRgQ=",
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

<br><br>

### 3.6. [Step 5] Enforce the column level access control

Before we enforce, here is the taxonomy and policy tag we created-

![README](../04-images/m06-15.png)   
<br><br>


Enforce by pasting in Cloud Shell-
```
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
LOCATION="us-central1"
FULLY_QUALIFIED_POLICY_TAG_ID="projects/$PROJECT_ID/locations/$LOCATION/taxonomies/$TAXONOMY_ID/policyTags/$FINANCIAL_POLICY_TAG_ID"

curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "x-goog-user-project: $PROJECT_ID" \
    -H "Content-Type: application/json; charset=utf-8" \
    --data "{\"dataPolicyType\":\"COLUMN_LEVEL_SECURITY_POLICY\", \"dataPolicyId\": \"$FINANCIAL_POLICY_TAG_ID\", \"policyTag\": \"$FULLY_QUALIFIED_POLICY_TAG_ID\" }" \
    "https://bigquerydatapolicy.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/dataPolicies"
```

Verify the same in the BigQuery UI-

![README](../04-images/m06-16.png)   
<br><br>

![README](../04-images/m06-17.png)   
<br><br>

![README](../04-images/m06-18.png)   
<br><br>


<hr>

## 4. Grant roles to the three users

Grant all the three users, the following roles:<br>
roles/viewer<br>
roles/storage.admin<br>
roles/dataproc.editor<br>

E.g. Substitute the users below with yours and run in Cloud Shell:

```
YOUR_YELLOW_TAXI_USER_EQUIVALENT="PASTE_EMAIL_HERE"
YOUR_GREEN_TAXI_USER_EQUIVALENT="PASTE_EMAIL_HERE"
YOUR_DATA_ENGINEER_USER_EQUIVALENT="PASTE_EMAIL_HERE"

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$YOUR_YELLOW_TAXI_USER_EQUIVALENT --role=roles/viewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$YOUR_GREEN_TAXI_USER_EQUIVALENT --role=roles/viewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$YOUR_DATA_ENGINEER_USER_EQUIVALENT --role=roles/viewer

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$YOUR_YELLOW_TAXI_USER_EQUIVALENT --role=roles/viewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$YOUR_GREEN_TAXI_USER_EQUIVALENT --role=roles/storage.admin
gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$YOUR_DATA_ENGINEER_USER_EQUIVALENT --role=roles/storage.admin

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$YOUR_YELLOW_TAXI_USER_EQUIVALENT --role=roles/viewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$YOUR_GREEN_TAXI_USER_EQUIVALENT --role=roles/dataproc.editor
gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$YOUR_DATA_ENGINEER_USER_EQUIVALENT --role=roles/dataproc.editor
```

<br><br>

<hr>

## 5. Column Level Security on BigLake tables **in action** with BQSQL from the BigQuery UI

To showcase column level security, we set up the following:

| User  |  Column Access |
| :-- | :--- |
| yellow-taxi-marketing-mgr | All columns | 
| green-taxi-marketing-mgr | All columns | 
| data-engineer |  All trips | All columns except fare, tips & total amount |

<br><br>

### 5.1. Sign-in to the BigQuery UI as the **data engineer** & query the table from the BigQuery UI

Paste in the BigQuery UI:

```
SELECT * FROM `apache-hudi-lab.gaia_product_ds.nyc_taxi_trips_hudi_biglake` LIMIT 2
```

You should see the following error:

![README](../04-images/m06-19.png)   
<br><br>

Paste in the BigQuery UI, columns other than fare_amount and tip_amount:

```
SELECT taxi_type, pickup_location_id, dropoff_location_id, pickup_datetime, dropoff_datetime FROM `apache-hudi-lab.gaia_product_ds.nyc_taxi_trips_hudi_biglake` LIMIT 2
```

You should see results returned. Effectively ONLY the Data Engineer is restricted from accessing the columns fare_amount and tip_amount as configured.

![README](../04-images/m06-20.png)   
<br><br>

### 5.2. Repeat exercise as yellow taxi user
Paste in the BigQuery UI:

```
SELECT * FROM `apache-hudi-lab.gaia_product_ds.nyc_taxi_trips_hudi_biglake` where taxi_type='yellow' LIMIT 2
```

You should see the rows returned.
<br><br>

### 5.3. Repeat exercise as green taxi user
Paste in the BigQuery UI:

```
SELECT * FROM `apache-hudi-lab.gaia_product_ds.nyc_taxi_trips_hudi_biglake` where taxi_type='green' LIMIT 2
```

You should see the rows returned.
<br><br>

<hr>

## 6. Configuring Column Level Security - masking - on BigLake tables 

Lets add masking to the setup we already did-

| User  |  Column Access | Access type | 
| :-- | :--- | :--- |
| yellow-taxi-marketing-mgr | All columns | Clear-text |
| green-taxi-marketing-mgr | All columns | Clear-text |
| data-engineer |  All trips | All columns except fare, tips & total amount | Masking of total_amount column |

<br><br>



### 6.1. Create a Dataproc "personal auth" cluster for the data engineer


### 6.2. Launch the exploration notebook on the BigLake table & run it


Note that 


## 7. Row Level Security on BigLake tables **in action** - with BQSQL from the BigQuery UI

To showcase row level security, we set up the following:

| User  |  Row Access |
| :-- | :--- |
| yellow-taxi-marketing-mgr | Only rows with taxi_type='yellow' | 
| green-taxi-marketing-mgr | Only rows with taxi_type='green' | 
| data-engineer |  All trips | All rows regardless of taxi_type |

<br>

### 7.1. Sign-in to the BigQuery UI as the **data engineer** & query the table from the BigQuery UI

Paste in the BigQuery UI:

```
(SELECT taxi_type, pickup_location_id, dropoff_location_id, pickup_datetime, dropoff_datetime FROM `apache-hudi-lab.gaia_product_ds.nyc_taxi_trips_hudi_biglake` 
where trip_year='2022' and trip_month='1' and trip_day='31' and taxi_type='yellow' limit 1)
UNION ALL
(SELECT taxi_type, pickup_location_id, dropoff_location_id, pickup_datetime, dropoff_datetime FROM `apache-hudi-lab.gaia_product_ds.nyc_taxi_trips_hudi_biglake`
where trip_year='2022' and trip_month='1' and trip_day='31' and taxi_type='green' limit 1)
```

You should see rows returned and no errors as we have excluded columns the data engineer is retricted from viewing.

![README](../04-images/m06-21.png)   
<br><br>

### 7.2. Sign-in to the BigQuery UI as the **yellow taxi marketing manager** & query the table from the BigQuery UI

Paste in the BigQuery UI:

```
(SELECT taxi_type, pickup_location_id, dropoff_location_id, pickup_datetime, dropoff_datetime FROM `apache-hudi-lab.gaia_product_ds.nyc_taxi_trips_hudi_biglake` 
where trip_year='2022' and trip_month='1' and trip_day='31' and taxi_type='yellow' limit 1)
UNION ALL
(SELECT taxi_type, pickup_location_id, dropoff_location_id, pickup_datetime, dropoff_datetime FROM `apache-hudi-lab.gaia_product_ds.nyc_taxi_trips_hudi_biglake`
where trip_year='2022' and trip_month='1' and trip_day='31' and taxi_type='green' limit 1)
```

You should see the warning --> "Your query results may be limited because you do not have access to certain rows" <-- and only rows granted access to are returned - in this case, yellow taxi trips ONLY.

![README](../04-images/m06-22.png)   
<br><br>

### 7.3. Sign-in to the BigQuery UI as the **green taxi marketing manager** & query the table from the BigQuery UI

Paste in the BigQuery UI:

```
(SELECT taxi_type, pickup_location_id, dropoff_location_id, pickup_datetime, dropoff_datetime FROM `apache-hudi-lab.gaia_product_ds.nyc_taxi_trips_hudi_biglake` 
where trip_year='2022' and trip_month='1' and trip_day='31' and taxi_type='yellow' limit 1)
UNION ALL
(SELECT taxi_type, pickup_location_id, dropoff_location_id, pickup_datetime, dropoff_datetime FROM `apache-hudi-lab.gaia_product_ds.nyc_taxi_trips_hudi_biglake`
where trip_year='2022' and trip_month='1' and trip_day='31' and taxi_type='green' limit 1)
```

You should see the warning --> "Your query results may be limited because you do not have access to certain rows" <-- and only rows granted access to are returned - in this case, green taxi trips ONLY.

![README](../04-images/m06-23.png)   
<br><br>

