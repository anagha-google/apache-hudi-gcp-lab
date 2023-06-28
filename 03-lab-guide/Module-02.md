# Module 2: Generate data for the lab

In this module, we will generate data for the lab that we will persist in our data lake in Cloud Storage. We will generate two flavors of persistence formats - Parquet and Hudi to showcase performance variations WRT BigLake queries. 

To make this lab also gently introduce capabilities in Dataproc for those new to it, the lab includes running a Spark Dataproc job from command line to read from BigQuery (with the Apache Spark BigQuery connector) and write to Cloud Storage as Parquet, and to generate the Hudi dataset, we will use Spark in a Jupyter notebook on Dataproc to read the Parquet dataset in Cloud Storage (with the Apache Spark Cloud Storage connector) and persist to Cloud Storage in Hudi format. 
   
**Lab Module Duration:** <br>
60 minutes 

**Prerequisite:** <br>
Successful completion of prior module

<hr>

## 1. About the data

### 1.1. Source
We will read the New York yellow and green taxi trip data in BigQuery public dataset into a canonical data model and perist to our data lake in Cloud Storage in Parquet and Hudi formats. 

|  |  |
| -- |:--- |
| Source for Yellow Taxi Tables |  bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_YYYY where YYYY is the year |
| Source for  Green Taxi Tables |  bigquery-public-data.new_york_taxi_trips.tlc_green_trips_YYYY where YYYY is the year  |
| Years of data | 2019, 2020, 2021, 2022 |


### 1.2. Data Model 

The NYC yellow and green taxi trips have different schemas. We have created a canonical data model and mapped the individual schemas of yellow taxi trips and green taxi trips to the same.
The following is the canonical schema-
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

### 1.3. Transformations 

The transformations done are captured in SQL format [here](../01-scirpts/bqsql/export_taxi_trips.sql).
The transformations however are applied in Spark, the technology used to generate the BigLake lab base datasets in Parquet and Hudi formats. 

### 1.4. Hive Parition Scheme

|  |  |
| -- |:--- |
| Hive partition scheme of target datasets |trip_year=YYYY/trip_month=XX/trip_day=XX/trip_hour=XX/trip_minute=XX|


### 1.5. Parquet and Hudi datasets in Cloud Storage

|  |  |
| -- |:--- |
| Cloud Storage Location - Parquet | gs://gaia-data-bucket-YOUR_PROJECT_NUMBER/nyc_taxi_trips/parquet|
| Cloud Storage Location - Hudi | gs://gaia-data-bucket-YOUR_PROJECT_NUMBER/nyc_taxi_trips/hudi|

### 1.6. Data stats

|  |  |
| -- |:--- |
| Total Trips | TBD |
| Total Yellow Trips | TBD |
| Total Green Trips | TBD |

<hr>

## 2. Data Generator Code

|  |  |
| -- |:--- |
| PySpark to read from BigQuery and persist to Cloud Storge as Parquet  | [Script](../01-scripts/pyspark/nyc_taxi_trips/nyc_taxi_data_generator_parquet.py) |
| PySpark to read Parquet from Cloud Storage and persist to Cloud Storge as Hudi  | [Notebook](../02-notebooks/nyc_taxi_trips/nyc_taxi_hudi_data_generator.ipynb) |

<hr>

## 3. Generate data in Parquet off of the BigQuery public NYC Taxi dataset

The commands below run the [Spark application](../01-scripts/pyspark/nyc_taxi_trips/nyc_taxi_data_generator_parquet.py) on dataproc on GCE. This takes ~35 minutes to complete.<br>
Paste the below in cloud shell-
```
# Variables
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
UMSA_FQN="gaia-lab-sa@$PROJECT_ID.iam.gserviceaccount.com"
DPGCE_CLUSTER_NM="gaia-dpgce-cpu-$PROJECT_NBR"
CODE_BUCKET="gs://gaia_code_bucket-$PROJECT_NBR/pyspark/nyc_taxi_trips"
DATA_BUCKET_FQP="gs://gaia_data_bucket-$PROJECT_NBR/nyc-taxi-trips/parquet-base"
DATAPROC_LOCATION="us-central1"

# Delete any data from a prior run
gsutil rm -r ${DATA_BUCKET_FQP}/

# Persist NYC Taxi trips to Cloud Storage in Parquet
gcloud dataproc jobs submit pyspark $CODE_BUCKET/nyc_taxi_data_generator_parquet.py \
--cluster $DPGCE_CLUSTER_NM \
--id nyc_taxi_data_generator_parquet_$RANDOM \
--region $DATAPROC_LOCATION \
--project $PROJECT_ID \
-- --projectID=$PROJECT_ID --peristencePath="$DATA_BUCKET_FQP" 

```

### 5.2. Generate data in Hudi off of the Parquet dataset in Cloud Storage

Review the code and then run the Spark [notebook](../02-notebooks/nyc_taxi_trips/nyc_taxi_hudi_data_generator.ipynb) on Dataproc on GCE from Jupyter to generate data in Hudi off of the Parquet dataset in Cloud Storage.<br>



