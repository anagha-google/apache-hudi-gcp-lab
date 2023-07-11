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

<br>

## Value proposition of BigLake for Hudi datasets

Note: BigLake is currently, a read-only external table framework; To add/update/delete data in your Hudi tables, you still need to use technologies such as Apache Spark on Cloud Dataproc. 

- BigLake offers **row, column level security** over Hudi (point-in-time) snapshots of Hudi tables in Cloud Storage
- BigLake **query acceleration** over Hudi (point-in-time) snapshots of Hudi tables in Cloud Storage.

## Architectural considerations for data engineering pipelines
- 1. You dont need to create a BigQuery and BigLake table each time, just the very first time.
- 2. Include syncing to BigQuery/BigLake metastore in your data engineering pipelines, for freshest data for querying via BQ SQL, with row and column level security enforced at read time
- 3. Refresh Biglake metadata cache if freshness is a must
  
<br>

## 1. Create a BigLake table definition over the Hudi snapshot parquet & manifest in GCS

### 1.1. Generate a SQL for the DDL command to be executed in BigQuery UI (one time activity)

Run this in Cloud Shell-
```
PROJECT_NM=`gcloud config get-value project`
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
LOCATION=us-central1
BQ_CONNECTION_NM=$LOCATION.gaia_bq_connection
HIVE_PARTITION_PREFIX="gs://gaia_data_bucket-$PROJECT_NBR/nyc-taxi-trips-hudi-cow/"
MANIFEST_FQP="${HIVE_PARTITION_PREFIX}.hoodie/absolute-path-manifest/latest-snapshot.csv"


DDL="CREATE OR REPLACE EXTERNAL TABLE gaia_product_ds.nyc_taxi_trips_hudi_biglake WITH PARTITION COLUMNS (trip_year string,trip_month string, trip_day string) WITH CONNECTION \`$PROJECT_NM.$BQ_CONNECTION_NM\` OPTIONS(uris=[\"$MANIFEST_FQP\"],hive_partition_uri_prefix =\"$HIVE_PARTITION_PREFIX\", format=\"PARQUET\",file_set_spec_type=\"NEW_LINE_DELIMITED_MANIFEST\",metadata_cache_mode=\"AUTOMATIC\",max_staleness=INTERVAL '1' DAY );"
echo $DDL
```

Capture the DDL emitted, we will paste this in the BigQuery UI.

![README](../04-images/m05-01.png)   
<br><br>


### 1.2. Run the DDL from the previous step in BigQuery UI

Create the BigLake table by running the DDL in the BigQuery UI.

![README](../04-images/m05-02.png)   
<br><br>

![README](../04-images/m05-03.png)   
<br><br>

<hr>

## 2. Query the Hudi snapshot BigLake table from BigQuery UI

<hr>

## 3. Query the Hudi snapshot BigLake table via Apache Spark

<hr>

## 4. Run the same query against the Hudi snapshot (plain old) BigQuery (not BigLake) external table

<hr>

## 5. Review performance benefits of BigLake



<hr>
This concludes the module. Please proceed to the next module.
