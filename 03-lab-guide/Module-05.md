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
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs````
LOCATION=us-central1
BQ_CONNECTION_NM=$LOCATION.gaia_bq_connection
MANIFEST_FQP="gs://gaia_data_bucket-$PROJECT_NBR/nyc-taxi-trips-hudi/.hoodie/manifest/last-snapshot.csv"

CREATE OR REPLACE EXTERNAL TABLE gaia_product_ds.nyc_taxi_trips_hudi WITH CONNECTION gaia_product_ds.$BQ_CONNECTION_NM OPTIONS(uris=[\"$MANIFEST_FQP\"], 
format=\"PARQUET\", 
file_set_spec_type=\"NEW_LINE_DELIMITED_MANIFEST\",
metadata_cache_mode=\"AUTOMATIC\",
max_staleness=INTERVAL '1' DAY );
```
