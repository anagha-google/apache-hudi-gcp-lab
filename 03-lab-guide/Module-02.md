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

We will use PySpark on Dataproc on GCE, using the Dataproc jobs API. The PySpark script is pre-created and uploaded to GCS as part of the Terraform provisioning. This step has deliberately not been automated so that you can subset/tune/tailor as needed.

