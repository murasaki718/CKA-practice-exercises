#!/bin/bash

# initial system update
sudo apt update -y && sudo apt upgrade -y
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# initial values
REGION="us-east-1"

META_DATA_API_URL='http://169.254.169.254/latest/meta-data'
META_DATA_INSTANCE_ID='instance-id'

# get IMDSv2 token
IMDS_TOKEN=$(curl -s -X PUT -H 'X-aws-ec2-metadata-token-ttl-seconds: 3600' 'http://169.254.169.254/latest/api/token')

# get instance-id from meta-data
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" "${META_DATA_API_URL}/${META_DATA_INSTANCE_ID}")

# helper function for getting information from tags
function get_tag () {

    if [ -z "$1" ]
    then
        echo "Must pass tag as arg to retrieve."
        exit 1
    else

        # gets all tags applied to the current instance
        # then queries out just the value, which is quoted,
        # then strips the quotes so just the raw value is returned
        local tag_value=$(aws --region $REGION ec2 describe-tags \
                            --filters Name=resource-id,Values=${INSTANCE_ID} Name=key,Values=${1} \
                            --query 'Tags[0].Value' | tr -d '"')

        # null check; what happens when you use an invalid tag
        if [ "$tag_value" = "null" ]
        then
            echo "Invalid tag chosen; null result."
            exit 1
        else
            echo "$tag_value"
        fi
    fi
}

### USER DATA SUPPLEMENT

# get name
INSTANCE_NAME=$(get_tag "Name")

# set hostname
hostnamectl set-hostname $INSTANCE_NAME

# set timezone
timedatectl set-timezone America/Chicago

### END HOSTNAME CONFIGURATION
