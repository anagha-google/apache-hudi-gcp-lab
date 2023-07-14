
# Module 6: Fine Grained Access Control powered by BigLake 

To run this lab module, you need the ability to create two users. If you dont, you can just read this module to understand Fine Grained Access Control possible with BigLake.

<hr>

## 1. Security setup

We will implement the following security setup-

| User example | Row Access | Column Access
| :-- | :--- |  :--- |  
| yellow-taxi-marketing-mgr@YOUR_DOMAIN.com |  Only yellow taxi trips | All columns | 
| green-taxi-marketing-mgr@YOUR_DOMAIN.com |  Only green taxi trips | All columns | 
| data-engineer@YOUR_DOMAIN.com |  All trips | All columns except fare and tips |

## 2. Create users 

From admin.google.com, create the three users.<br>

<hr>

## 3. Create access policies for Row Level Security (RLS)

### 3.1. Create a policy for Yellow Taxi data

In the sample below, the author is granting "yellow-taxi-marketing-mgr" access to yellow taxi data. Edit it to reflect your user.<br>
Run the command below, after updating with your user, in the BigQuery UI-
```
CREATE OR REPLACE ROW ACCESS POLICY yellow_taxi_filter
ON gaia_product_ds.nyc_taxi_trips_hudi_biglake
GRANT TO ("user:yellow-taxi-marketing-mgr@akhanolkar.altostrat.com")
FILTER USING (taxi_type = "yellow")
```

### 3.2. Create a policy for Green Taxi data

In the sample below, the author is granting "green-taxi-marketing-mgr" access to green taxi data. Edit it to reflect your user.<br>
Run the command below, after updating with your user, in the BigQuery UI-
```
CREATE OR REPLACE ROW ACCESS POLICY green_taxi_filter
ON gaia_product_ds.nyc_taxi_trips_hudi_biglake
GRANT TO ("user:green-taxi-marketing-mgr@akhanolkar.altostrat.com")
FILTER USING (taxi_type = "green")
```

<hr>

## 4. Create access policies for Column Level Security (CLS)

### 4.1. Create a taxonomy called "BusinessCritical-NYCT"

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

### 4.2. Create a policy tag called "FinancialData" under the taxonomy

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

### 4.3. Assign the policy to the data-engineer to disallow them from accessing financials

Run this in Cloud Shell, after editing the command to reflect your data-engineer email:
```
DATA_ENGINEER_EMAIL="data-engineer@akhanolkar.altostrat.com"

curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "x-goog-user-project: $PROJECT_ID" \
    -H "Content-Type: application/json; charset=utf-8" \
  https://datacatalog.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/taxonomies/$TAXONOMY_ID/policyTags/${FINANCIAL_POLICY_TAG_ID}:setIamPolicy -d  "{\"policy\":{\"bindings\":[{\"role\":\"roles/datacatalog.categoryFineGrainedReader\",\"members\":[\"user:$DATA_ENGINEER_EMAIL\"]}]}}"
```

Author's output:
```
INFORMATIONAL-
{
  "version": 1,
  "etag": "BwYAas+l/7g=",
  "bindings": [
    {
      "role": "roles/datacatalog.categoryFineGrainedReader",
      "members": [
        "user:data-engineer@akhanolkar.altostrat.com"
      ]
    }
  ]
}
```

## 5. Column Level Security in action

### 5.1. Sign-in to the BigQuery UI as the data engineer & query the table

Paste in the BigQuery UI:
