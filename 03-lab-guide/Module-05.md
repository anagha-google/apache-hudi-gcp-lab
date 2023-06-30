# Module 5: BigLake external tables with metadata acceleration on Hudi datasets

BigLake is feature that provides the following capabilities-
1. An external table abstraction over structured data in Cloud Storage in supported formats.
2. Query acceleration through metadata caching, statistics capture and more
3. Greater security over data lakes through row level security, column level security and data masking made possible with a set of commands
4. Biglake offers decoupling security over external tables from underlying storage (grant access to table without granting access to data in Cloud Storage)
5. Requires creation of a 

You can upgrade a BigQuery external table to a BigLake table. 

## 1. Create a BigLake table over the Hudi snapshot parquet & manifest in GCS

```
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
LOCATION=us-central1
BQ_CONNECTION_NM=$LOCATION.gaia_bq_connection
MANIFEST_FQP="gs://gaia_data_bucket-$PROJECT_NBR/nyc-taxi-trips-hudi/.hoodie/manifest/latest-snapshot.csv"

DDL="CREATE OR REPLACE EXTERNAL TABLE gaia_product_ds.nyc_taxi_trips_hudi WITH PARTITION COLUMNS (trip_year string,trip_month string, trip_day string) WITH CONNECTION gaia_product_ds.$BQ_CONNECTION_NM OPTIONS(uris=[\"$MANIFEST_FQP\"], format=\"PARQUET\",file_set_spec_type=\"NEW_LINE_DELIMITED_MANIFEST\",metadata_cache_mode=\"AUTOMATIC\",max_staleness=INTERVAL '1' DAY );"
echo $DDL

````

Lakshmi Bobba, 17 min
CREATE OR REPLACE EXTERNAL TABLE
  `bq-huron.demo_biglake.hudi_nyc_bl`
WITH PARTITION COLUMNS (
  EventDate string
)
WITH CONNECTION `bq-huron.us.cmeta_connection`
OPTIONS(
hive_partition_uri_prefix = "gs://biglake-demo-wordcount/hudi/taxi-trips-query-acceleration/",
uris=['gs://biglake-demo-wordcount/hudi/taxi-trips-query-acceleration/.hoodie/absolute-path-manifest/latest-snapshot.csv'],
file_set_spec_type='NEW_LINE_DELIMITED_MANIFEST',
metadata_cache_mode="AUTOMATIC",
max_staleness=INTERVAL '1' DAY,
format="PARQUET")


SELECT DATE(Pickup_DateTime) AS PICKUP_DATE,
ROUND(SUM(fare_amount),0) as TotalFares,
COUNT(*) AS TRIP_CT
FROM `bq-huron.demo_biglake.hudi_nyc_bl`
WHERE EventDate = '2021-03-29'
GROUP BY 1
ORDER BY 1;

```
