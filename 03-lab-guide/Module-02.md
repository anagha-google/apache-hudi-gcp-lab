# Module 2: Generate data for the lab

In this module, we will generate data for the lab that we will persist in our data lake in Cloud Storage. We will generate two flavors of persistence formats - Parquet and Hudi to showcase performance variations.
   
**Lab Module Duration:** <br>
30 minutes 

**Prerequisite:** <br>
Suvvessful completion of prior module

## 1. About the data

We will read the New York Taxi yellow and green taxi data in BigQuery public dataset into a canonical data model and perist to our data lake in Cloud Storage in Parquet and Hudi formats. 

|  |  |
| -- |:--- |
| Base Yellow Taxi Tables |  bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_YYYY where YYYY is the year |
| Base Green Taxi Tables |  bigquery-public-data.new_york_taxi_trips.tlc_green_trips_YYYY where YYYY is the year  |
| Total Row Count | |
| Query used to generate | |
| Hive partition scheme |trip_year=YYYY/trip_month=XX/trip_day=XX/trip_hour=XX/trip_minute=XX|
| Cloud Storage Location - Parquet | gs://gaia-data-bucket-YOUR_PROJECT_NUMBER/nyc_taxi_trips/parquet|
| Cloud Storage Location - Hudi | gs://gaia-data-bucket-YOUR_PROJECT_NUMBER/nyc_taxi_trips/hudi|
