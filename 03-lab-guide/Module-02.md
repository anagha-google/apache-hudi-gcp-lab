# Module 2: Generate data for the lab

In this module, we will generate data for the lab that we will persist in our data lake in Cloud Storage. We will generate two flavors of persistence formats - Parquet and Hudi to showcase performance variations.
   
**Lab Module Duration:** <br>
30 minutes 

**Prerequisite:** <br>
Successful completion of prior module

## 1. About the data

We will read the New York Taxi yellow and green taxi data in BigQuery public dataset into a canonical data model and perist to our data lake in Cloud Storage in Parquet and Hudi formats. 

|  |  |
| -- |:--- |
| Base Yellow Taxi Tables |  bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_YYYY where YYYY is the year |
| Base Green Taxi Tables |  bigquery-public-data.new_york_taxi_trips.tlc_green_trips_YYYY where YYYY is the year  |
| Total Row Count | 1,213,620,063 |
| Query used to generate | [export_taxi_trips.sql](../01-scripts/bqsql/export_taxi_trips.sql) |
| Hive partition scheme |trip_year=YYYY/trip_month=XX/trip_day=XX/trip_hour=XX/trip_minute=XX|
| Cloud Storage Location - Parquet | gs://gaia-data-bucket-YOUR_PROJECT_NUMBER/nyc_taxi_trips/parquet|
| Cloud Storage Location - Hudi | gs://gaia-data-bucket-YOUR_PROJECT_NUMBER/nyc_taxi_trips/hudi|

## 2. Canonical Data Model for NYC Yellow and Green taxi trip data

The following is the schema-
```
root
 |-- taxi_type: string (nullable = true)
 |-- trip_year: long (nullable = true)
 |-- trip_month: long (nullable = true)
 |-- trip_day: long (nullable = true)
 |-- trip_hour: long (nullable = true)
 |-- trip_minute: long (nullable = true)
 |-- vendor_id: string (nullable = true)
 |-- pickup_datetime: timestamp (nullable = true)
 |-- dropoff_datetime: timestamp (nullable = true)
 |-- store_and_forward: string (nullable = true)
 |-- rate_code: string (nullable = true)
 |-- pickup_location_id: string (nullable = true)
 |-- dropoff_location_id: string (nullable = true)
 |-- passenger_count: long (nullable = true)
 |-- trip_distance: decimal(38,9) (nullable = true)
 |-- fare_amount: decimal(38,9) (nullable = true)
 |-- surcharge: decimal(38,9) (nullable = true)
 |-- mta_tax: decimal(38,9) (nullable = true)
 |-- tip_amount: decimal(38,9) (nullable = true)
 |-- tolls_amount: decimal(38,9) (nullable = true)
 |-- improvement_surcharge: decimal(38,9) (nullable = true)
 |-- total_amount: decimal(38,9) (nullable = true)
 |-- payment_type_code: string (nullable = true)
 |-- congestion_surcharge: decimal(38,9) (nullable = true)
 |-- trip_type: string (nullable = true)
 |-- ehail_fee: decimal(38,9) (nullable = true)
 |-- partition_date: date (nullable = true)
 |-- distance_between_service: decimal(38,9) (nullable = true)
 |-- time_between_service: long (nullable = true)

```

## 2. Data Generator Code

We will use PySpark on Dataproc on GCE, using the Dataproc jobs API. The PySpark script is pre-created and uploaded to GCS as part of the Terraform provisioning. This step has deliberately not been automated so that you can subset/tune/tailor as needed.<br>


[Review the code for Parquet](../01-scripts/pyspark/nyc_taxi_data_generator_parquet.py)<br>
[Review the code for Hudi](../01-scripts/pyspark/nyc_taxi_data_generator_parquet.py)<br>

## 3. Generate data

### 3.1. Generate data in Parquet 

The commands below run the [Spark application]((../01-scripts/pyspark/nyc_taxi_data_generator_parquet.py)) on dataproc on GCE.<br>
Paste the below in cloud shell-
```
# Variables
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
UMSA_FQN="gaia-lab-sa@$PROJECT_ID.iam.gserviceaccount.com"
TARGET_BUCKET_GCS_URI="gs://gaia_data_bucket-$PROJECT_NBR/nyc_taxi_trips/parquet"
DPGCE_CLUSTER_NM="gaia-dpgce-cpu-$PROJECT_NBR"
CODE_BUCKET="gs://gaia_code_bucket-$PROJECT_NBR/nyc-taxi-data-generator"
DATA_BUCKET="gs://gaia_data_bucket-$PROJECT_NBR/"
DATAPROC_LOCATION="us-central1"
BQ_LOCATION_MULTI="us"
SPARK_BQ_CONNETCOR_SCRATCH_DATASET="gaia_scratch_ds"

# Delete any data from a prior run
gsutil rm -r ${TARGET_BUCKET_GCS_URI}

# Persist NYC Taxi trips to Cloud Storage in Parquet
gcloud dataproc jobs submit pyspark $CODE_BUCKET/nyc_taxi_data_generator_parquet.py \
--cluster $DPGCE_CLUSTER_NM \
--id nyc_taxi_data_generator_parquet_$RANDOM \
--region $DATAPROC_LOCATION \
--project $PROJECT_ID \
-- --projectID=$PROJECT_ID --bqScratchDataset=$SPARK_BQ_CONNETCOR_SCRATCH_DATASET --peristencePath="$DATA_BUCKET" 

```
