#!/bin/bash

#........................................................................
# Purpose: Apply service updates where there is no Terraform support yet
#........................................................................

# Variables
PROJECT_ID=`gcloud config list --format 'value(core.project)'`
DPMS_NM=$1
REGION=$2

gcloud beta metastore services update $DPMS_NM --location $REGION --project $PROJECT_ID --data-catalog-sync 
