# Module 5: BigLake external tables on Hudi snapshots

## BigLake in a nutshell
BigLake is feature that provides the following capabilities-
1. A readonly  external table abstraction over structured data in Cloud Storage in supported formats.
2. Query acceleration through metadata caching, statistics capture and more
3. Greater security over data lakes through row level security, column level security and data masking made possible with a set of commands
4. Biglake offers decoupling of security - external tables from underlying storage (grant access to table without granting access to data in Cloud Storage)
5. Run queries from BigQuery UI on BigQuery native tables and BigLake tables seamlessly
6. Read/write to BigQuery and BigLake tables seamlessly from Apache Spark on Dataproc
7. Read from BigQuery and BigLake tables seamlessly and visualize with your favorite dashboarding solution

## Value proposition of BigLake for Hudi datasets

Note: BigLake is a read-only external table framework; To add/update/delete data in your Hudi tables, you still need to use technologies such as Apache Spark on Cloud Dataproc. 

- BigLake offers **row, column level security**
- BigLake **query acceleration** over Hudi (point-in-time) snapshots of Hudi tables in Cloud Storage.
As part of your data engineering pipelines, run the BigQuerySyncTool to provide end users the latest data. Then do a BigLake metadata refresh.

## 1. Create a BigLake table definition over the Hudi snapshot parquet & manifest in GCS

### 1.1. Generate a SQL for the DDL command to be executed in BigQuery UI

Run this in Cloud Shell-
```
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
LOCATION=us-central1
BQ_CONNECTION_NM=$LOCATION.gaia_bq_connection
MANIFEST_FQP="gs://gaia_data_bucket-$PROJECT_NBR/nyc-taxi-trips-hudi/.hoodie/manifest/latest-snapshot.csv"

DDL="CREATE OR REPLACE EXTERNAL TABLE gaia_product_ds.nyc_taxi_trips_hudi WITH PARTITION COLUMNS (trip_year string,trip_month string, trip_day string) WITH CONNECTION gaia_product_ds.$BQ_CONNECTION_NM OPTIONS(uris=[\"$MANIFEST_FQP\"], format=\"PARQUET\",file_set_spec_type=\"NEW_LINE_DELIMITED_MANIFEST\",metadata_cache_mode=\"AUTOMATIC\",max_staleness=INTERVAL '1' DAY );"
echo $DDL
```

Capture the DDL emitted, we will paste this in the BigQuery UI.

### 1.2. Run the DDL from the previous step in BigQuery UI

Create the BigLake table by running the DDL in the BigQuery UI.


## 2. Query the Hudi snapshot BigLake table from BigQuery UI



## 3. Query the Hudi snapshot BigLake table via Apache Spark


## 4. Run the same query against the Hudi snapshot (plain old) BigQuery (not BigLake) external table


## 5. Review performance benefits of BigLake

<br>
This concludes the module. Please proceed to the next module.
