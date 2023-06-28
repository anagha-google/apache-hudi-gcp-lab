# Module 3: Sync the Hudi metadata into Dataproc Metastore & work with. theHudi table from Spark SQL anywhere

```
### 7.1. Find the Public IP address of your Cloud Shell terminal

```
MY_IP_ADDRESS=`curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`
echo $MY_IP_ADDRESS
```

### 7.2. Add an ingress firewall rule to allow yourself SSH access to the cluster
First and foremost, you need to allow yourself ingress to SSH into the cluster. If you use Cloud Shell, the IP address varies with each session. Use the commad below to allow ingress to your IP address.
```
PROJECT_ID=`gcloud config list --format "value(core.project)" 2>/dev/null`
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
VPC_NM=gaia-vpc-$PROJECT_NBR
REGION=us-central1
ZONE=$REGION-a
CLUSTER_NAME=gaia-dpgce-cpu-$PROJECT_NBR
MY_FIREWALL_RULE="allow-me-to-ingress-into-vpc"

gcloud compute firewall-rules delete $MY_FIREWALL_RULE

gcloud compute --project=$PROJECT_ID firewall-rules create $MY_FIREWALL_RULE --direction=INGRESS --priority=1000 --network=$VPC_NM --action=ALLOW --rules=all --source-ranges="$MY_IP_ADDRESS/32"
```
