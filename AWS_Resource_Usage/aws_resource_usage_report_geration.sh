#!/bin/bash
#############################################
#Author:Bhuvanesh(Support Team)
#Date created:12/12/2025

#AWS Resource Usage Monitoring Report
#############################################

#Resources
#S3
#IAM
#EC2
#LAMBDA FUNCTION
#
set -e
set -o pipefail

if [ ! -d ~/.aws ];
then 
	echo "AWS is not configured"
fi
if command -v aws &>/dev/null ;
then 
	echo "aws was not installed"
fi

mkdir -p Logs
log="Logs/log-$(date +%F-%H-%M-%S).log"
echo "##### AWS Resource Usage Monitoring Report ######" >> "$log"

echo -e "\n1)List of IAM Users" >> "$log"
aws iam list-users | jq -r '.Users[].UserName' >> "$log"

echo -e "\n2)Running EC2 instances" >> "$log"
aws ec2 describe-instances | jq -r '.Reservations[].Instances[].InstanceId' >> "$log"

echo -e "\n3)List of S3 in Use" >> "$log"
aws s3 ls >> "$log"

#Deleting the 7 days old logs
find Logs/ -type f -mtime +7 -delete

echo "Report saved to the LOG"
