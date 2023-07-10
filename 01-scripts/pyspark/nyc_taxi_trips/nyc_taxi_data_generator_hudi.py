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
