#!/bin/bash
RunningEC2=()
StoppedEC2=()
datetime=$(date '+%y-%m-%d %H:%M:%S')
LOG_FILE="watchdog.log"
trap 'echo "Error occoured at lineno $LINENO"' ERR

log(){
local LEVEL=$1
shift
local LOG_LEVEL="INFO"
local message="$*"

if [[  "$LEVEL" == "ERROR" ]];
then
    echo  "$datetime [$LEVEL] $message" | tee -a "$LOG_FILE"
elif [[ "$LEVEL" == "DEBUG" &&  "$LOG_LEVEL" != "DEBUG" ]];
then  
    return
else 
  echo  "$datetime [$LEVEL] $message" | tee -a "$LOG_FILE"
fi     
}

RunningEC2=$(aws ec2 describe-instances \
                                --filters "Name=instance-state-name,Values=running" \
                                --query "Reservations[].Instances[].InstanceId" \
                                --output text)
StoppedEC2=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=stopped" \
    --query "Reservations[].Instances[].InstanceId" \
    --output text)
if [[ ! -z "$StoppedEC2" ]];
then
   log INFO "THES ARE THE INSTANCES ARE IN STOPPED STATE $StoppedEC2"
for sid in  "${StoppedEC2[@]}";
do
  status=$(aws ec2 start-instances --instance-ids $sid)
  log INFO "Instance $sid Getting Started"
done
fi
