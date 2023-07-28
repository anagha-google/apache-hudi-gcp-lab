# ............................................................
# Generate NYC Taxi trips in Parquet
# ............................................................
# This script -
# 1. Reads BQ public dataset tables with NYC yellow taxi trips and 
# 2. Reads BQ public dataset tables with NYC green taxi trips and 
# 3. Homogenizes the schema across the datasets and
# 4. Unions the two datasets and
# 5. Persists to GCS as parquet in the 
# 6. Hive partition scheme of trip_date=YYYY_MM_DD
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
        '--peristencePath',
        help='GCS location to persist output',
        type=str,
        required=True)
    return argsParser.parse_args()
# }} End fnParseArguments()

def fnMain(logger, args):
# {{ Start main

    # 1. Capture Spark application input
    projectID = args.projectID
    peristencePath = args.peristencePath

    # 2. Query to read BQ 
    YELLOW_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE="SELECT DISTINCT 'yellow' as taxi_type,substring(pickup_datetime,0,10) as trip_date,extract(year from pickup_datetime) as trip_year,extract(month from pickup_datetime) as trip_month,extract(day from pickup_datetime) as trip_day,extract(hour from pickup_datetime) as trip_hour, extract(minute from pickup_datetime) as trip_minute,vendor_id as vendor_id, pickup_datetime as pickup_datetime, dropoff_datetime as dropoff_datetime, store_and_fwd_flag as store_and_forward, Rate_Code as rate_code, pickup_location_id as pickup_location_id, dropoff_location_id as dropoff_location_id, Passenger_Count as passenger_count, trip_distance, fare_amount, imp_surcharge as surcharge, mta_tax as mta_tax, tip_amount, tolls_amount,cast(null as numeric) as improvement_surcharge,total_amount,payment_type as payment_type_code,cast(null as numeric) as congestion_surcharge, cast(null as string) as trip_type,cast(null as numeric) as ehail_fee,date(pickup_datetime) as partition_date,cast(null as numeric) as distance_between_service,cast(null as integer) as time_between_service from yellow_taxi_trips where extract(year from pickup_datetime)=YYYY"
    print("YELLOW_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE: ")
    print(YELLOW_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE)
    
    GREEN_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE="SELECT DISTINCT 'green' as taxi_type,substring(pickup_datetime,0,10) as trip_date,extract(year from pickup_datetime) as trip_year, extract(month from pickup_datetime) as trip_month, extract(day from pickup_datetime) as trip_day, extract(hour from pickup_datetime) as trip_hour, extract(minute from pickup_datetime) as trip_minute, vendor_id as vendor_id, pickup_datetime as pickup_datetime, dropoff_datetime as dropoff_datetime, store_and_fwd_flag as store_and_forward, Rate_Code as rate_code, pickup_location_id as pickup_location_id, dropoff_location_id as dropoff_location_id, Passenger_Count as passenger_count, trip_distance , fare_amount, imp_surcharge as surcharge, mta_tax, tip_amount, tolls_amount, cast(null as numeric) as improvement_surcharge, total_amount, payment_type as payment_type_code, cast(null as numeric) as congestion_surcharge, trip_type, cast(Ehail_Fee as numeric) as ehail_fee, date(pickup_datetime) as partition_date, distance_between_service, time_between_service FROM green_taxi_trips WHERE extract(year from pickup_datetime)=YYYY"
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
            # ...................................................................................

            # ..Read from BQ
            yellowTaxiTripsDF = spark.read \
              .format('bigquery') \
              .load(f"bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_{taxi_trip_year}")

            # ..Create a temp table
            yellowTaxiTripsDF.createOrReplaceTempView("yellow_taxi_trips")

            # ..Count
            yellowTripCount=yellowTaxiTripsHomogenizedDF.count()
            print(f"Yellow trip count=str({yellowTripCount})")

            # ..Load a dataframe with yellow taxi trips in a canonical schema (common for yellow and green taxis)
            yellowTaxiTripsHomogenizedDF=spark.sql(YELLOW_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE.replace("YYYY",str(taxi_trip_year)))


            
            
            # Read green taxi data, canonicalize the schema
            # ...................................................................................

            # ..Read from BQ
            greenTaxiTripsDF = spark.read \
              .format('bigquery') \
              .load(f"bigquery-public-data.new_york_taxi_trips.tlc_green_trips_{taxi_trip_year}")

            # ..Create a temp table
            greenTaxiTripsDF.createOrReplaceTempView("green_taxi_trips")

            # ..Count
            greenTripCount=greenTaxiTripsHomogenizedDF.count()
            print(f"Green trip count=str({greenTripCount})")

             # ..Load a dataframe with yellow taxi trips in a canonical schema (common for yellow and green taxis)
            greenTaxiTripsHomogenizedDF=spark.sql(GREEN_TRIPS_HOMOGENIZED_SCHEMA_QUERY_BASE.replace("YYYY",str(taxi_trip_year)))

        
            # Prepare to persist

            # ..Union the two dataframes
            taxiTripsHomogenizedUnionedDF=yellowTaxiTripsHomogenizedDF.union(greenTaxiTripsHomogenizedDF)

            # ..Add a unique key
            taxiTripsHomogenizedKeyedDF=taxiTripsHomogenizedUnionedDF.withColumn("trip_id", monotonically_increasing_id())

            # ..Count
            taxiTripsCountForTheYear=taxiTripsHomogenizedUnionedDF.count()
            print(f"Trip count for the year=str({taxiTripsCountForTheYear})")
        
            # ..Persist
            print(f"Starting write for year {taxi_trip_year}...")
            taxiTripsHomogenizedKeyedDF.write.partitionBy("trip_date").parquet(f"{peristencePath}", mode='append')
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
