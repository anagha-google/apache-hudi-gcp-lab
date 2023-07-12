# Module 3: Generate Hudi data for the lab

In this module we will generate Hudi (base) data for the lab, based off of the Parquet data from the previous module and we will persist to our data lake in Cloud Storage.

We will do the data generation via a PySpark script that is pre-created and available in this repo, (and in your cloud storage code bucket), and then explore the Hudi dataset from a pre-created Dataproc Jupyter notebook attached to your cluster. The script also creates an external table defintion on the Hudi dataset in Dataproc Metastore (Apache Hive Metastore). There are some sample Spark SQL queries to explore the data in the notebook.

**Prerequisite:** <br>
Successful completion of prior module

<hr>

## Lab Module Goals

Fundamentaly, this module covers creating a Hudi dataset of NYC taxi trip data available in Cloud Storage as a Parquet dataset. The following are implicit. The lab also introduces Jupyter Spark notebooks on Dataproc on Compute Engine if unfamiliar.

## Lab Module Flow

![README](../04-images/m03-00-1.png)   
<br><br>

## Lab Module Solution Architecture 

![README](../04-images/m03-00-2.png)   
<br><br>
   
## Lab Module Duration 
40 minutes or less.

<hr>

## 1. About the data in Parquet

NYC (yellow and green) taxi trip data in Parquet in Cloud Storage. You can review the file listing from Cloud Shell with the commands below-


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
```
INFORMATIONAL
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
```

### 1.2. The number of files
Number of files
```
gsutil ls -r $DATA_BUCKET_PARQUET_FQP | wc -l
```

Author's output: 127,018

### 1.3. The size of the data
```
gsutil du -sh gs://gaia_data_bucket-$PROJECT_NBR
```

Author's output: 8.07 GiB

<hr>

## 2. Generate a Hudi (CoW) dataset in Cloud Storage

### 2.1. Review the source code

The following is the source code, pasted for a quick visual. Refer to the latest source code is available at this [link](../01-scripts/pyspark/nyc_taxi_trips/nyc_taxi_data_generator_hudi.py)<br>

```
# ............................................................
# Generate NYC Taxi trips in Hudi format
# ............................................................
# This script -
# 1. Reads a Parquet dataset tables with NYC yellow & Green taxi trips and 
# 2. Persists to GCS as Hudi in the 
# 3. Hive partition scheme of trip_year=YYYY/trip_month=MM,/trip_day=DD
# ............................................................


import sys,logging,argparse
import pyspark
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from datetime import datetime
from google.cloud import storage
import datetime

def fnParseArguments():
# {{ Start 
    """
    Purpose:
        Parse arguments received by script
    Returns:
        args
    """
    argsParser = argparse.ArgumentParser()
    argsParser.add_argument(
        '--peristencePathInput',
        help='GCS location of Parquet dataset',
        type=str,
        required=True)
    argsParser.add_argument(
    '--peristencePathOutput',
    help='GCS location of Hudi dataset',
    type=str,
    required=True)
    return argsParser.parse_args()
# }} End fnParseArguments()


def fnMain(logger, args):
# {{ Start main

    # 0. Capture Spark application input
    logger.info('....Application input')
    PARQUET_BASE_GCS_URI = args.peristencePathInput
    HUDI_BASE_GCS_URI = args.peristencePathOutput
    logger.info('....===================================')    


    # 1. Get or create Spark Session with requisite Hudi configs

    logger.info('....Initializing spark & spark configs')
    spark = SparkSession.builder \
      .appName("NYC Taxi Hudi Data Generator-PySpark") \
      .master("yarn")\
      .enableHiveSupport()\
      .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.hudi.catalog.HoodieCatalog") \
      .config("spark.sql.extensions", "org.apache.spark.sql.hudi.HoodieSparkSessionExtension") \
      .getOrCreate()

    spark
    logger.info('....===================================')


    # 2. Other variables

    logger.info('....Defining other vars')
    DATABASE_NAME="taxi_db"
    TABLE_NAME="nyc_taxi_trips_hudi"
    logger.info('....===================================')

    try:
        # 3. Create database in Apache Hive Metastore
        # The Dataproc cluster was created with an existing Dataproc Metatsore Service referenced as Apache Hive Metastore

        logger.info('....Create database in Apache Hive Metastore')
        # Create database
        spark.sql(f"create database if not exists {DATABASE_NAME};").show()
        # Drop any existing tables 
        spark.sql(f"drop table if exists {DATABASE_NAME}.{TABLE_NAME}").show()
        logger.info('....===================================')

        # 4. Read Taxi trips in Parquet format in Cloud Storage and persist as Hudi
        logger.info('....Start processing to Hudi format')
        startTime = datetime.datetime.now()
        print(f"Started at {startTime}")

        # 4.1. Read Parquet from Cloud Storage
        tripsDF=spark.read.format("parquet").load(PARQUET_BASE_GCS_URI)
        tripsDF.createOrReplaceTempView("temp_trips")
        tripsDF.rdd.getNumPartitions()

        # 4.2. Persist as Hudi to Cloud Storage
        hudi_options = {
            'hoodie.database.name': DATABASE_NAME,
            'hoodie.table.name': TABLE_NAME,
            'hoodie.datasource.write.table.name': TABLE_NAME,
            'hoodie.datasource.write.table.type': 'COPY_ON_WRITE',
            'hoodie.datasource.write.keygenerator.class':'org.apache.hudi.keygen.CustomKeyGenerator',
            'hoodie.datasource.write.recordkey.field': 'taxi_type,trip_year,trip_month,trip_day,vendor_id,pickup_datetime,dropoff_datetime,pickup_location_id,dropoff_location_id',
            'hoodie.datasource.write.partitionpath.field': 'trip_year:SIMPLE,trip_month:SIMPLE,trip_day:SIMPLE',
            'hoodie.datasource.write.precombine.field': 'pickup_datetime',
            'hoodie.datasource.write.hive_style_partitioning': 'true',
            'hoodie.partition.metafile.use.base.format': 'true', 
            'hoodie.datasource.write.drop.partition.columns': 'true'
        }


        taxi_trip_years_list = [2019,2020,2021,2022]

        for taxi_trip_year in taxi_trip_years_list:
            print("==================================")
            print(f"TRIP YEAR={taxi_trip_year}")

            tripsYearScopedDF = spark.sql(f"SELECT * FROM temp_trips where trip_year={taxi_trip_year}")

            tripsYearScopedDF.write.format("hudi"). \
                options(**hudi_options). \
                mode("append"). \
                save(HUDI_BASE_GCS_URI)

        print(f"Completed write for year {taxi_trip_year}...")
        print("==================================")


        completionTime = datetime.datetime.now()
        print(f"Completed at {completionTime}")

        logger.info('....===================================')

        # 5. Register table in Dataproc Metastore Service
        # As part of Terraform for provisioning automation, a managed Hive Metastore was created for you - Dataproc Metastore Service with thrift endpoint.
        logger.info('....Register table in Dataproc Metastore Service')
        spark.sql("SHOW DATABASES;").show(truncate=False)
        # Create an external table on the Hudi files in the data lake in Cloud Storage
        spark.sql(f"CREATE TABLE IF NOT EXISTS {DATABASE_NAME}.{TABLE_NAME} USING hudi LOCATION \"{HUDI_BASE_GCS_URI}\";").show()

        print("Completed persisting parquet taxi data as Hudi")
        print("==================================")
               
    except RuntimeError as coreError:
            logger.error(coreError)
    else:
        logger.info('Successfully completed persisting NYC taxi trips!')
        
# }} End fnMain()

def fnConfigureLogger():
# {{ Start 
    """
    Purpose:
        Configure a logger for the script
    Returns:
        Logger object
    """
    logFormatter = logging.Formatter('%(asctime)s - %(filename)s - %(levelname)s - %(message)s')
    logger = logging.getLogger("data_engineering")
    logger.setLevel(logging.INFO)
    logger.propagate = False
    logStreamHandler = logging.StreamHandler(sys.stdout)
    logStreamHandler.setFormatter(logFormatter)
    logger.addHandler(logStreamHandler)
    return logger
# }} End fnConfigureLogger()

if __name__ == "__main__":
    arguments = fnParseArguments()
    logger = fnConfigureLogger()
    fnMain(logger, arguments)
```


### 2.2. Run the following script in Cloud Shell

This Dataproc can be tuned further for performance.
```
# Variables
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
UMSA_FQN="gaia-lab-sa@$PROJECT_ID.iam.gserviceaccount.com"
DPGCE_CLUSTER_NM="gaia-dpgce-cpu-$PROJECT_NBR"
CODE_BUCKET="gs://gaia_code_bucket-$PROJECT_NBR/pyspark/nyc_taxi_trips"
DATA_BUCKET_PARQUET_FQP="gs://gaia_data_bucket-$PROJECT_NBR/nyc-taxi-trips-parquet"
DATA_BUCKET_HUDI_FQP="gs://gaia_data_bucket-$PROJECT_NBR/nyc-taxi-trips-hudi-cow"
DATAPROC_LOCATION="us-central1"

# Delete any data from a prior run
gsutil rm -r ${DATA_BUCKET_HUDI_FQP}/

# Persist NYC Taxi trips to Cloud Storage in Parquet
gcloud dataproc jobs submit pyspark $CODE_BUCKET/nyc_taxi_data_generator_hudi.py \
--cluster $DPGCE_CLUSTER_NM \
--id nyc_taxi_data_generator_hudi_$RANDOM \
--region $DATAPROC_LOCATION \
--project $PROJECT_ID \
--properties "spark.executor.memory=4g" \
--  --peristencePathInput="$DATA_BUCKET_PARQUET_FQP" --peristencePathOutput="$DATA_BUCKET_HUDI_FQP" 
```


<hr>

## 3. Review the persisted data layout & details in Cloud Storage

### 3.1. The layout

Run this in Cloud Shell-
```
# Variables
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
DATA_BUCKET_HUDI_FQP="gs://gaia_data_bucket-$PROJECT_NBR/nyc-taxi-trips-hudi-cow"

# List some files to get a view of the hive paritioning scheme
gsutil ls $DATA_BUCKET_HUDI_FQP/ | head -10

```

Author's output:
```
INFORMATIONAL
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/trip_year=2019/
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/trip_year=2020/
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/trip_year=2021/
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/trip_year=2022/
```

### 3.2. The number of Hudi files

Number of files
```
gsutil ls -r $DATA_BUCKET_HUDI_FQP | wc -l
```

Author's output: 
7933<br>
(versus 127,018 for Parquet format)<br>
We will learn about the disparity in module 9

### 3.3. The size of the data
No compression code was explicitly specified.
The Hudi dataset is uncompressed.
(versus Parquet - compressed with snappy by default)
```
gsutil du -sh $DATA_BUCKET_HUDI_FQP
```

Author's output: 
8.2 GiB 
(versus 8 GiB of (snappy compressed) Parquet)<br>
We will learn about the disparity in module 9

### 3.4. The metadata

We will learn more about the metadata in the module 9
```
gsutil ls -r $DATA_BUCKET_HUDI_FQP/.hoodie
```

The author's output-
```
INFORMATIONAL
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/20230710174218046.commit
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/20230710174218046.commit.requested
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/20230710174218046.inflight
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/20230710180034357.commit
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/20230710180034357.commit.requested
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/20230710180034357.inflight
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/20230710180539428.commit
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/20230710180539428.commit.requested
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/20230710180539428.inflight
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/20230710181127186.commit
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/20230710181127186.commit.requested
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/20230710181127186.inflight
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/hoodie.properties

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/.aux/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/.aux/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/.aux/.bootstrap/:

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/.aux/.bootstrap/.fileids/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/.aux/.bootstrap/.fileids/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/.aux/.bootstrap/.partitions/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/.aux/.bootstrap/.partitions/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/.schema/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/.schema/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/.temp/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/.temp/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/archived/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/archived/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/00000000000000.deltacommit
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/00000000000000.deltacommit.inflight
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/00000000000000.deltacommit.requested
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/20230710174218046.deltacommit
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/20230710174218046.deltacommit.inflight
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/20230710174218046.deltacommit.requested
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/20230710180034357.deltacommit
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/20230710180034357.deltacommit.inflight
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/20230710180034357.deltacommit.requested
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/20230710180539428.deltacommit
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/20230710180539428.deltacommit.inflight
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/20230710180539428.deltacommit.requested
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/20230710181127186.deltacommit
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/20230710181127186.deltacommit.inflight
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/20230710181127186.deltacommit.requested
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/hoodie.properties

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.aux/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.aux/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.aux/.bootstrap/:

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.aux/.bootstrap/.fileids/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.aux/.bootstrap/.fileids/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.aux/.bootstrap/.partitions/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.aux/.bootstrap/.partitions/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.heartbeat/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.heartbeat/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.schema/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.schema/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.temp/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/.temp/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/archived/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/.hoodie/archived/

gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/files/:
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/files/
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/files/.files-0000_00000000000000.log.1_0-0-0
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/files/.files-0000_00000000000000.log.1_0-7-7
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/files/.files-0000_00000000000000.log.2_0-38-6203
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/files/.files-0000_00000000000000.log.3_0-70-9325
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/files/.files-0000_00000000000000.log.4_0-102-12496
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/files/.files-0000_00000000000000.log.5_0-137-15623
gs://gaia_data_bucket-623600433888/nyc-taxi-trips-hudi-cow/.hoodie/metadata/files/.hoodie_partition_metadata
admin_@cloudshell:~ (apache-hudi-lab)$ 

```


<hr>

## 4. Explore the dataset in a Jupyter notebook
Navigate to Jupyter on Dataproc and run the notebook nyc_taxi_hudi_data_generator.ipynb as shown below-

![README](../04-images/m03-01.png)   
<br><br>

![README](../04-images/m03-02.png)   
<br><br>

![README](../04-images/m03-06.png)   
<br><br>

![README](../04-images/m03-07.png)   
<br><br>


<hr>

## 5. Taxi trip count
This is from the notebook.<br><br>

Hudi dataset-
```
+---------+------------+
|trip_year|trip_count  |
+---------+------------+
|     2019|  90,690,529|
|     2020|  26,192,443|
|     2021|  31,845,761|
|     2022|  36,821,513|
+---------+------------+
```

Parquet dataset-
```
+---------+--------------------+
|trip_year|parquet_trip_count  |
+---------+--------------------+
|     2019|          90,897,542|
|     2020|          26,369,825|
|     2021|          31,972,637|
|     2022|          37,023,925|
+---------+--------------------+
```

The counts are slightly different due to the author's choice of composite Hudi record key (column combination) and the Hudi precombine field. Because its not a material difference relative to the lab goals, we will proceed with the lab.

<hr>

This concludes module 3, please proceed to the [next module](Module-04.md).

