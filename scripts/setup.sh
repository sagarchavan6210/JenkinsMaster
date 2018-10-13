#!/bin/bash

set -e
set +xv ## Do not remove

info_n() { echo -e "\e[36m$@\e[0m" 1>&2 ; }
info() { echo "" ; info_n $* ; }
warn() { echo ""; echo -e "\e[33m$@\e[0m" 1>&2; }
die() { echo -e "\e[31m$@\e[0m" 1>&2 ; exit 1; }

function inputValidation(){

	# Get Region Name
	if [ $Region == 'neur' ]
	then
	  REGION_AZ="North Europe"
	  
	elif [ $Region == 'weur' ]
	then
	  REGION_AZ="West Europe"
	fi
}

function configureAz(){
      info "Configuring Az..."
      az login --service-principal -u ${client_id} -p ${client_secret} --tenant a6aefcb5-d166-4bbc-be10-bf4cdbdb39d4
      az account set --subscription $subscription_id
}
function GetStorageKEY(){
  configureAz
  info "Geting Storage KEY"
  #ACCESS_KEY=${account_key}
  ACCESS_KEY=`az storage account keys list --account-name $AZURE_STORAGE_ACCOUNT --resource-group $RESOURCEGROUP |grep -i "value" | head -1 | awk -F'"' '{print $4}'`

  if [[ -z $ACCESS_KEY ]]; then
    die "unable to get AZURE_STORAGE_ACCESS_KEY for $AZURE_STORAGE_ACCOUNT"
  fi
  info "Creating container: $CONTAINER"
  az storage container create -n "$CONTAINER" --account-key $ACCESS_KEY
  export AZURE_STORAGE_ACCESS_KEY=$ACCESS_KEY
}

function createtfvars(){
  GetStorageKEY
  COMMON_STORAGE_ACCESS_KEY=`az storage account keys list --account-name $AZURE_COMMON_STORAGE_ACCOUNT --resource-group $COMMON_RESOURCE_GROUP |grep -i "value" | head -1 | awk -F'"' '{print $4}'`
  deploy_timestamp=$(date +%s%3N)
  
  info "creating custom tfvars"
  echo """
    subscription_id = \"$subscription_id\"
    client_id = \"$client_id\"
    client_secret = \"$client_secret\"
    tenant_id = \"$tenant_id\"
    location = \"$REGION_AZ\"
    environment = \"$Environment\"
	trs_storage_acc_name = \"$AZURE_STORAGE_ACCOUNT\"
    trs_container_name = \"$CONTAINER\"
    trs_key = \"globalinfra.tfstate\"
    trs_access_key= \"$AZURE_STORAGE_ACCESS_KEY\"
    protected_settings = {
    storageAccountName = \"${AZURE_COMMON_STORAGE_ACCOUNT}\"
    storageAccountKey  = \"${COMMON_STORAGE_ACCESS_KEY}\"
    }
    vm_password = \"${vm_password}\"
    vm_username = \"${vm_username}\"
    deploy_timestamp = \"${deploy_timestamp}\"
		""" > creds.tfvars
}

    
function run(){
  duty=$1
  pwd
  case $duty in
    "plan")
	  createtfvars
      terraform get
      terraform -v
      terraform init -backend-config "storage_account_name=$AZURE_STORAGE_ACCOUNT" -backend-config "container_name=$CONTAINER" -backend-config "key=jenkins-master.tfstate" -backend-config "access_key=$AZURE_STORAGE_ACCESS_KEY" -force-copy
      terraform plan -var-file=reference.tfvars -var-file=creds.tfvars
    ;;
    "apply")
      createtfvars
      terraform get
      terraform init -backend-config "storage_account_name=$AZURE_STORAGE_ACCOUNT" -backend-config "container_name=$CONTAINER" -backend-config "key=jenkins-master.tfstate" -backend-config "access_key=$AZURE_STORAGE_ACCESS_KEY" -force-copy
      echo yes| terraform apply -var-file=reference.tfvars -var-file=creds.tfvars
    ;;
    "destroy")
      createtfvars
      terraform get
      terraform init -backend-config "storage_account_name=$AZURE_STORAGE_ACCOUNT" -backend-config "container_name=$CONTAINER" -backend-config "key=jenkins-master.tfstate" -backend-config "access_key=$AZURE_STORAGE_ACCESS_KEY" -force-copy 
      echo yes| terraform destroy -var-file=reference.tfvars -var-file=creds.tfvars
  ;;
  *)
  ;;
  esac
}

hostname=`hostname`
inputValidation
export BLOB_POSTFIX=infra
export AZURE_STORAGE_ACCOUNT="storageacc_tfstate"
export RESOURCEGROUP="rg_of_tfstatest"
export AZURE_COMMON_STORAGE_ACCOUNT="stoarageacc_script"
export COMMON_RESOURCE_GROUP="resource_rg"
export CONTAINER="tfstate-containername"

info "#################################### Variable Details ##################################"

  info_n "AZURE_REGION          = $REGION_AZ"
  info_n "AZURE_STORAGE_ACCOUNT = $AZURE_STORAGE_ACCOUNT"
  info_n "CONTAINER             = $CONTAINER"
  info_n "RESOURCEGROUP         = $RESOURCEGROUP"
  info_n "SUBSCRIPTION_ID       = $subscription_id"
  info_n "HOSTNAME              = $hostname"

info "########################################################################################"

run $1
