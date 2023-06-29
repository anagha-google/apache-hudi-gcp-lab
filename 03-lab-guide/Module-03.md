# Module 3: Generate Hudi data for the lab

In this module and next, we will generate Hudi (base) data for the lab, based off of the Parquet data from the previous module and we will persist to our data lake in Cloud Storage.

We will do the data generation in Dataproc Jupyter Notebooks. A pre-created notebook is already attached to your cluster. We will merely run the same. The notebook also creates an external table on the Hudi dataset in Dataproc Metastore (Apache Hive Metastore). There are some sample Spark SQL queries to explore the data in the notebook.
   
**Lab Module Duration:** <br>
30 minutes 

**Prerequisite:** <br>
Successful completion of prior module

<hr>

## 1. About the data in Parquet

NYC (yellow and green) taxi trip data in Parquet in Cloud Storage. The data is **deliberately** a tad over-partitioned considering the small size of the overall dataset, and with small files to show metadata acceleration made possible with BigLake. You can review the file listing from Cloud Shell with the commands below-


### 1.1. The layout
```
# Variables
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
DATA_BUCKET_PARQUET_FQP="gs://gaia_data_bucket-$PROJECT_NBR/nyc-taxi-trips-parquet"


# List some files to get a view of the hive paritioning scheme
gsutil ls -r $DATA_BUCKET_PARQUET_FQP | head -20
```
Author's output:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/_SUCCESS

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/trip_month=1/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/trip_month=1/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/trip_month=1/trip_day=1/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/trip_month=1/trip_day=1/
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/trip_month=1/trip_day=1/part-00000-7c5db3b2-8584-458f-a1df-471740bd4750.c000.snappy.parquet
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/trip_month=1/trip_day=1/part-00001-7c5db3b2-8584-458f-a1df-471740bd4750.c000.snappy.parquet
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/trip_month=1/trip_day=1/part-00002-7c5db3b2-8584-458f-a1df-471740bd4750.c000.snappy.parquet
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/trip_month=1/trip_day=1/part-00003-7c5db3b2-8584-458f-a1df-471740bd4750.c000.snappy.parquet
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/trip_month=1/trip_day=1/part-00004-7c5db3b2-8584-458f-a1df-471740bd4750.c000.snappy.parquet
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/trip_month=1/trip_day=1/part-00005-7c5db3b2-8584-458f-a1df-471740bd4750.c000.snappy.parquet
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/trip_month=1/trip_day=1/part-00006-7c5db3b2-8584-458f-a1df-471740bd4750.c000.snappy.parquet
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-parquet/trip_year=2019/trip_month=1/trip_day=1/part-00007-7c5db3b2-8584-458f-a1df-471740bd4750.c000.snappy.parquet

### 1.2. The number of files
Number of files
```
gsutil ls -r $DATA_BUCKET_PARQUET_FQP | wc -l
```

Author's output: 127018

### 1.3. The size of the data
```
gsutil du -sh gs://gaia_data_bucket-$PROJECT_NBR
```

Author's output: 8.07 GiB

<hr>

## 3. Generate a Hudi (CoW) dataset in Cloud Storage

Navigate to Jupyter on Dataproc and run ththe notebook nyc_taxi_hudi_data_generator.ipynb as shown below-

