# Module 3: Generate Hudi data for the lab

In this module and next, we will generate Hudi (base) data for the lab, based off of the Parquet data from the previous module and we will persist to our data lake in Cloud Storage.

We will do the data generation in Dataproc Jupyter Notebooks. A pre-created notebook is already attached to your cluster. We will merely run the same. The notebook also creates an external table on the Hudi dataset in Dataproc Metastore (Apache Hive Metastore). There are some sample Spark SQL queries to explore the data in the notebook.
   
**Lab Module Duration:** <br>
30 minutes 

**Prerequisite:** <br>
Successful completion of prior module

<hr>

## 1. About the data

NYC (yellow and green) taxi trip data in Parquet in Cloud Storage. The data is **deliberately** a tad over-partitioned considering the small size of the overall dataset, and with small files to show metadata acceleration made possible with BigLake. You can review the file listing from Cloud Shell with the commands below-
```

```


