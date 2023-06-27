# This is an UNUSED informational script that is representative of the data sourced from BigQuery for the lab
SELECT
    'yellow' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax as mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    cast(null as string) as trip_type,   
    cast(null as numeric) as ehail_fee,   
    date(pickup_datetime) as partition_date,
    cast(null as numeric) as distance_between_service,
    cast(null as integer) as time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
    WHERE extract(year from pickup_datetime)=2022
    UNION ALL
    SELECT 
    'green' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance ,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    trip_type as trip_type, 
    cast(Ehail_Fee as numeric) as ehail_fee,
    date(pickup_datetime) as partition_date,
    distance_between_service,
    time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2022`
    WHERE extract(year from pickup_datetime)=2022
    UNION ALL
    SELECT
    'yellow' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax as mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    cast(null as string) as trip_type,   
    cast(null as numeric) as ehail_fee,   
    date(pickup_datetime) as partition_date,
    cast(null as numeric) as distance_between_service,
    cast(null as integer) as time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021`
    WHERE extract(year from pickup_datetime)=2021
    UNION ALL
    SELECT'green' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance ,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    trip_type as trip_type, 
    cast(Ehail_Fee as numeric) as ehail_fee,
    date(pickup_datetime) as partition_date,
    distance_between_service,
    time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2021`
    WHERE extract(year from pickup_datetime)=2021
    UNION ALL
    SELECT
    'yellow' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax as mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    cast(null as string) as trip_type,   
    cast(null as numeric) as ehail_fee,   
    date(pickup_datetime) as partition_date,
    cast(null as numeric) as distance_between_service,
    cast(null as integer) as time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`
    WHERE extract(year from pickup_datetime)=2020
    UNION ALL
    SELECT'green' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance ,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    trip_type as trip_type, 
    cast(Ehail_Fee as numeric) as ehail_fee,
    date(pickup_datetime) as partition_date,
    distance_between_service,
    time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2020`
    WHERE extract(year from pickup_datetime)=2020
    UNION ALL
    SELECT
    'yellow' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax as mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    cast(null as string) as trip_type,   
    cast(null as numeric) as ehail_fee,   
    date(pickup_datetime) as partition_date,
    cast(null as numeric) as distance_between_service,
    cast(null as integer) as time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2019`
    WHERE extract(year from pickup_datetime)=2019
    UNION ALL
    SELECT'green' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance ,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    trip_type as trip_type, 
    cast(Ehail_Fee as numeric) as ehail_fee,
    date(pickup_datetime) as partition_date,
    distance_between_service,
    time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2019`
    WHERE extract(year from pickup_datetime)=2019
    UNION ALL
    SELECT
    'yellow' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax as mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    cast(null as string) as trip_type,   
    cast(null as numeric) as ehail_fee,   
    date(pickup_datetime) as partition_date,
    cast(null as numeric) as distance_between_service,
    cast(null as integer) as time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2018`
    WHERE extract(year from pickup_datetime)=2018
    UNION ALL
    SELECT'green' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance ,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    trip_type as trip_type, 
    cast(Ehail_Fee as numeric) as ehail_fee,
    date(pickup_datetime) as partition_date,
    distance_between_service,
    time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2018`
    WHERE extract(year from pickup_datetime)=2018
    UNION ALL
    SELECT
    'yellow' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax as mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    cast(null as string) as trip_type,   
    cast(null as numeric) as ehail_fee,   
    date(pickup_datetime) as partition_date,
    cast(null as numeric) as distance_between_service,
    cast(null as integer) as time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2017`
    WHERE extract(year from pickup_datetime)=2017
    UNION ALL
    SELECT'green' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance ,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    trip_type as trip_type, 
    cast(Ehail_Fee as numeric) as ehail_fee,
    date(pickup_datetime) as partition_date,
    distance_between_service,
    time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2017`
    WHERE extract(year from pickup_datetime)=2017
    UNION ALL
    SELECT
    'yellow' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax as mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    cast(null as string) as trip_type,   
    cast(null as numeric) as ehail_fee,   
    date(pickup_datetime) as partition_date,
    cast(null as numeric) as distance_between_service,
    cast(null as integer) as time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2016`
    WHERE extract(year from pickup_datetime)=2016
    UNION ALL
    SELECT'green' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance ,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    trip_type as trip_type, 
    cast(Ehail_Fee as numeric) as ehail_fee,
    date(pickup_datetime) as partition_date,
    distance_between_service,
    time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2016`
    WHERE extract(year from pickup_datetime)=2016
    UNION ALL
    SELECT
    'yellow' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax as mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    cast(null as string) as trip_type,   
    cast(null as numeric) as ehail_fee,   
    date(pickup_datetime) as partition_date,
    cast(null as numeric) as distance_between_service,
    cast(null as integer) as time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2015`
    WHERE extract(year from pickup_datetime)=2015
    UNION ALL
    SELECT'green' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance ,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    trip_type as trip_type, 
    cast(Ehail_Fee as numeric) as ehail_fee,
    date(pickup_datetime) as partition_date,
    distance_between_service,
    time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2015`
    WHERE extract(year from pickup_datetime)=2015
    UNION ALL
    SELECT
    'yellow' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax as mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    cast(null as string) as trip_type,   
    cast(null as numeric) as ehail_fee,   
    date(pickup_datetime) as partition_date,
    cast(null as numeric) as distance_between_service,
    cast(null as integer) as time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2014`
    WHERE extract(year from pickup_datetime)=2014
    UNION ALL
    SELECT'green' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance ,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    trip_type as trip_type, 
    cast(Ehail_Fee as numeric) as ehail_fee,
    date(pickup_datetime) as partition_date,
    distance_between_service,
    time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2014`
    WHERE extract(year from pickup_datetime)=2014
    UNION ALL
    SELECT
    'yellow' as taxi_type,
    extract(year from pickup_datetime) as trip_year,
    extract(month from pickup_datetime) as trip_month,
    extract(day from pickup_datetime) as trip_day,
    extract(hour from pickup_datetime) as trip_hour,
    extract(minute from pickup_datetime) as trip_minute,
    vendor_id as vendor_id,
    pickup_datetime as pickup_datetime,
    dropoff_datetime as dropoff_datetime,
    store_and_fwd_flag as store_and_forward,
    Rate_Code as rate_code,
    pickup_location_id as pickup_location_id,
    dropoff_location_id as dropoff_location_id,
    Passenger_Count as passenger_count,
    trip_distance,
    fare_amount,
    imp_surcharge as surcharge,
    mta_tax as mta_tax,
    tip_amount,
    tolls_amount,
    cast(null as numeric) as improvement_surcharge,
    total_amount,
    payment_type as payment_type_code,
    cast(null as numeric) as congestion_surcharge,
    cast(null as string) as trip_type,   
    cast(null as numeric) as ehail_fee,   
    date(pickup_datetime) as partition_date,
    cast(null as numeric) as distance_between_service,
    cast(null as integer) as time_between_service
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2013`
    WHERE extract(year from pickup_datetime)=2013
