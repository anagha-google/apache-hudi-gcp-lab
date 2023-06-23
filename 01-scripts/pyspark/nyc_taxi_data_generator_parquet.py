# ............................................................
# Generate NYC Taxi trips
# ............................................................
# This script -
# 1. Reads a BQ public dataset table with NYC Taxi trips
# 2. Persists to GCS as parquet
# ............................................................

import sys,logging,argparse
import pyspark
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from datetime import datetime
from google.cloud import storage


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
        '--projectID',
        help='Project ID',
        type=str,
        required=True)
    argsParser.add_argument(
        '--bqScratchDataset',
        help='Materialization dataset used by Spark BQ connector for query pushdown',
        type=str,
        required=True)
    argsParser.add_argument(
        '--peristencePath',
        help='GCS location to persist output',
        type=str,
        required=True)
    return argsParser.parse_args()
# }} End fnParseArguments()

def fnDeleteSuccessFlagFile(bucket_uri):
# {{ Start 
    """Deletes a blob from the bucket."""
    # bucket_name = "your-bucket-name"
    # blob_name = "your-object-name"

    storage_client = storage.Client()
    bucket_name = bucket_uri.split("/")[2]
    object_name = "/".join(bucket_uri.split("/")[3:]) 

    print(f"Bucket name: {bucket_name}")
    print(f"Object name: {object_name}")

    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(f"{object_name}_SUCCESS")
    blob.delete()

    print(f"_SUCCESS file deleted.")
# }} End

def fnMain(logger, args):
# {{ Start main

    # 1. Capture Spark application input
    projectID = args.projectID
    bqScratchDataset = args.bqScratchDataset
    peristencePath = args.peristencePath

    # 2. Query to read BQ 
    YELLOW_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE="SELECT DISTINCT 'yellow' as taxi_type,extract(year from pickup_datetime) as trip_year,extract(month from pickup_datetime) as trip_month,extract(day from pickup_datetime) as trip_day,extract(hour from pickup_datetime) as trip_hour, extract(minute from pickup_datetime) as trip_minute,vendor_id as vendor_id, pickup_datetime as pickup_datetime, dropoff_datetime as dropoff_datetime, store_and_fwd_flag as store_and_forward, Rate_Code as rate_code, pickup_location_id as pickup_location_id, dropoff_location_id as dropoff_location_id, Passenger_Count as passenger_count, trip_distance, fare_amount, imp_surcharge as surcharge, mta_tax as mta_tax, tip_amount, tolls_amount,cast(null as numeric) as improvement_surcharge,total_amount,payment_type as payment_type_code,cast(null as numeric) as congestion_surcharge, cast(null as string) as trip_type,cast(null as numeric) as ehail_fee,date(pickup_datetime) as partition_date,cast(null as numeric) as distance_between_service,cast(null as integer) as time_between_service from yellow_taxi_trips where extract(year from pickup_datetime)=YYYY"
    print("YELLOW_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE: ")
    print(YELLOW_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE)
    
    GREEN_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE="SELECT DISTINCT 'green' as taxi_type, extract(year from pickup_datetime) as trip_year, extract(month from pickup_datetime) as trip_month, extract(day from pickup_datetime) as trip_day, extract(hour from pickup_datetime) as trip_hour, extract(minute from pickup_datetime) as trip_minute, vendor_id as vendor_id, pickup_datetime as pickup_datetime, dropoff_datetime as dropoff_datetime, store_and_fwd_flag as store_and_forward, Rate_Code as rate_code, pickup_location_id as pickup_location_id, dropoff_location_id as dropoff_location_id, Passenger_Count as passenger_count, trip_distance , fare_amount, imp_surcharge as surcharge, mta_tax, tip_amount, tolls_amount, cast(null as numeric) as improvement_surcharge, total_amount, payment_type as payment_type_code, cast(null as numeric) as congestion_surcharge, trip_type, cast(Ehail_Fee as numeric) as ehail_fee, date(pickup_datetime) as partition_date, distance_between_service, time_between_service FROM green_taxi_trips WHERE extract(year from pickup_datetime)=YYYY"
    print("GREEN_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE: ")
    print(GREEN_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE)

    # 3. Create Spark session
    logger.info('....Initializing spark & spark configs')
    spark = SparkSession.builder.appName("NYC Taxi trip dataset generator").getOrCreate()
    logger.info('....===================================')

    try:
        taxi_trip_years_list = [2019,2020,2021,2022]

        for taxi_trip_year in taxi_trip_years_list:
            print("==================================")
            print(f"TRIP YEAR={taxi_trip_year}")
            
            # Read yellow taxi data, canonicalize the schema
            yellowTaxiTripsDF = spark.read \
              .format('bigquery') \
              .load(f"bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_{taxi_trip_year}")
            yellowTaxiTripsDF.createOrReplaceTempView("yellow_taxi_trips")
            yellowTaxiTripsHomogenizedDF=spark.sql(YELLOW_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE.replace("YYYY",str(taxi_trip_year)))
            yellowTripCount=yellowTaxiTripsHomogenizedDF.count()
            print(f"Yellow trip count=str({yellowTripCount})")
            
            
            # Read green taxi data, canonicalize the schema
            greenTaxiTripsDF = spark.read \
              .format('bigquery') \
              .load(f"bigquery-public-data.new_york_taxi_trips.tlc_green_trips_{taxi_trip_year}")
            greenTaxiTripsDF.createOrReplaceTempView("green_taxi_trips")
            greenTaxiTripsHomogenizedDF=spark.sql(GREEN_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE.replace("YYYY",str(taxi_trip_year)))
            greenTripCount=greenTaxiTripsHomogenizedDF.count()
            print(f"Green trip count=str({greenTripCount})")
        
            taxiTripsHomogenizedUnionedDF=yellowTaxiTripsHomogenizedDF.union(greenTaxiTripsHomogenizedDF)
            taxiTripsCountForTheYear=taxiTripsHomogenizedUnionedDF.count()
            print(f"Trip count for the year=str({taxiTripsCountForTheYear})")
        
            print(f"Starting write for year {taxi_trip_year}...")
            taxiTripsHomogenizedUnionedDF.write.partitionBy("trip_year","trip_month","trip_day").parquet(f"{peristencePath}", mode='append')
            print(f"Completed write for year {taxi_trip_year}...")
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
