# Module 4: Create BigQuery external tables on Hudi datasets in your data lake

This lab module introduces Apache Hudi tooling for integrating Hudi tables in a data lake on Cloud Storage into BigQuery as external tables.

## 1. Native Apache Hudi integration tooling for BigQuery

### 1.1. About
Apache Hudi offers a BigQuerySyncTool - a utility that reads Hudi metadata of a Hudi table in Cloud Storage, and creates a BigQuery external table on the same data. This external table is read only and can be queried using BigQuery SQL from the BigQuery UI and other supported BigQuery querying avenues and uses BigQuery compute under the hood.

Learn more about the tooling in the [Apache Hudi documentation](https://hudi.apache.org/docs/gcp_bigquery/).

### 1.2. Under the hood

The sync tool syncs a Hudi table at a time, and requires running a Spark application. 
Upon launching the app-
1. It creates a manifest file reflecting the latest snapshot of the table, and persists the same in the .hoodie directory of the Hudi dataset.
2. It creates two tables in BigQuery and one (virtual) BigQuery view

### 1.3. Querying the Hudi dataset in BigQuery
To query the Hudi dataset, one must query the view.<br>

### 1.4. Architectural considerations
1. The manifest is point in time snapshot, therefore the view reflects point in time state of the Hudi dataset. Run the sync tool as frequently as you need to query fresh data
2. The view is virtual and executes a join of two tables each time you run the query
3. Deletion of underlying Hudi files will result in query failures

### 1.5. What is takes to use the tooling as it stands

1. Build Hudi from source (requires Java 8)
2. Copy the same to cluster
3. Run the Spark application that uses the BigQuerySyncTool

### 1.6. What's coming in Dataproc

The BigQuerySyncTool will be included as part of the base Dataproc image.
<br>


## 2. The lab

<br>
