#!/bin/bash

set -e
set +xv ## Do not remove

info_n() { echo -e "\e[36m$@\e[0m" 1>&2 ; }
info() { echo "" ; info_n $* ; }
warn() { echo ""; echo -e "\e[33m$@\e[0m" 1>&2; }
die() { echo -e "\e[31m$@\e[0m" 1>&2 ; exit 1; }

function inputValidation(){
      info "inside inputValidation"
}

function configureAWS(){
      info "Configuring AWS..."
      
      aws s3 mb s3://${BUCKET_NAME} --region ${AWS_REGION} --endpoint-url https://s3.${AWS_REGION}.amazonaws.com
      #aws s3 cp "s3://frombucket/testfile.txt" "s3://$1/testfile.txt"
}


function createtfvars(){
      info "create creds tfvar"
}

    
function run(){
  duty=$1
  pwd
  case $duty in
    "plan")
      echo "In plan stage"
      configureAWS
      #createtfvars
      terraform get
      terraform -v
      terraform init --backend-config="access_key=$AWS_KEY" --backend-config="secret_key=$AWS_SECRET" -force-copy
      terraform plan
      #terraform plan -var-file=reference.tfvars -var-file=creds.tfvars
    ;;
    "apply")
      echo "In apply stage"
      #createtfvars
      terraform get
      terraform init -backend-config="access_key=$AWS_KEY" -backend-config="secret_key=$AWS_SECRET" -backend-config "key=jenkins-master.tfstate" -force-copy
      echo yes| terraform apply
      #echo yes| terraform apply -var-file=reference.tfvars -var-file=creds.tfvars
    ;;
    "destroy")
      echo "In destroy stage"
      #createtfvars
      terraform get
      terraform init -backend-config="access_key=$AWS_KEY" -backend-config="secret_key=$AWS_SECRET" -backend-config "key=jenkins-master.tfstate" -force-copy
      echo yes| terraform destroy
      #echo yes| terraform destroy -var-file=reference.tfvars -var-file=creds.tfvars
  ;;
  *)
  ;;
  esac
}

hostname=`hostname`
inputValidation
export BUCKET_NAME='jenkins-infra-tfstate'
export AWS_REGION='us-east-1'
export AWS_KEY=''
export AWS_SECRET=''
info "#################################### Variable Details ##################################"

  info_n "AWS_REGION            = $AWS_REGION"
  info_n "S3BUCKET_NAME		      = $BUCKET_NAME"
  info_n "HOSTNAME              = $hostname"

info "########################################################################################"

run $1
