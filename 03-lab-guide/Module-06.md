
# Module 6: Fine Grained Access Control powered by BigLake 

WORK IN PROGRESS

<hr>

## 1. Security setup

## 1.1. Create IAM groups

Create three IAM groups, as shown below.


## 1.2. Create IAM users belonging to the three groups






## 3. Create access policies for Row Level Security (RLS)

### 3.1. Create a policy for Yellow Taxi data

In the sample below, the author is granting the group "yellow-taxi-marketing-mgr" access to yellow taxi data. Edit it to reflect your user. <br>
Run the command below, after updating with your user, in the BigQuery UI-
```
YELLOW_TAXI_GROUP_EMAIL="PASTE_YOUR_GROUP_HERE"
CREATE OR REPLACE ROW ACCESS POLICY yellow_taxi_rap
ON gaia_product_ds.nyc_taxi_trips_hudi_biglake
GRANT TO ("group:$YELLOW_TAXI_GROUP_EMAIL")
FILTER USING (taxi_type = "yellow")
```

### 3.2. Create a policy for Green Taxi data

In the sample below, the author is granting "green-taxi-marketing-mgr" access to green taxi data. Edit it to reflect your user.<br>
Run the command below, after updating with your user, in the BigQuery UI-
```
GREEN_TAXI_GROUP_EMAIL="PASTE_YOUR_GROUP_HERE"
CREATE OR REPLACE ROW ACCESS POLICY green_taxi_rap
ON gaia_product_ds.nyc_taxi_trips_hudi_biglake
GRANT TO ("group:$GREEN_TAXI_GROUP_EMAIL")
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

### 4.3. Associate the policy with specific columns in the BigLake table

### 4.4. Assign the policy to the taxi marketing managers to allow access to financials

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

<hr>

## 5. Grant roles to the three users

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

<hr>

## 6. Column Level Security in action

To showcase column level security, we set up the following:

| User  |  Column Access |
| :-- | :--- |
| yellow-taxi-marketing-mgr | All columns | 
| green-taxi-marketing-mgr | All columns | 
| data-engineer |  All trips | All columns except fare, tips & total amount |

### 6.1. Sign-in to the BigQuery UI as the **data engineer** & query the table from the BigQuery UI

Paste in the BigQuery UI:

```

```

