#!/bin/bash
#set -x
Entries=()
LOG_FILE="watchdog.log"
trap 'echo "Error occoured at lineno $LINENO"' ERR
trap 'log ERROR "Interupt by the user ";exit 1' SIGINT



retry(){
local MAX_ATTEMP=$1
shift
local count=1

while [[  "$count" -le "$MAX_ATTEMP" ]];
do       
         "$@" && return  0
         echo "$?"
         echo "Atempt $count"

          ((count++))
         sleep 10
done
log ERROR "After $MAX_ATTEMP attempt the service couldnt started need intenal validation "
return 1
}
log(){
    local datetime=$(date '+%y-%m-%d %H:%M:%S')
    local LEVEL=$1
    shift
    local LOG_LEVEL="INFO"
    local message="$*"

    if [[  "$LEVEL" == "ERROR" ]];
    then
        echo  "$datetime [$LEVEL] $message" | tee -a "$LOG_FILE" >&2
elif [[ "$LEVEL" == "DEBUG" &&  "$LOG_LEVEL" != "DEBUG" ]];
    then
        return
    else
        echo  "$datetime [$LEVEL] $message" | tee -a "$LOG_FILE" >&2
    fi
}

fetch_instances_inventory(){
    retry 3 aws ec2 describe-instances \
        --query "Reservations[].Instances[].[InstanceId,State.Name]" \
        --output text
}

monitoring_cycle(){
    mapfile -t Entries < <(fetch_instances_inventory)
    for entry in "${Entries[@]}";
    do

        id=$(echo "$entry" | awk '{print $1}')
        state=$(echo "$entry" | awk '{print $2}')

        case "$state" in
            running)
                log INFO "Instance $id is healthy"
                ;;
            stopped)
                log INFO "Instance $id is stopped"
                status=$(retry 3 aws ec2 start-instances --instance-ids $id)
                log INFO "Instance $id Getting Started"
                ;;
            stopping)
                log INFO "Instance $id is currenly stopping"
                ;;
            shutting-down)
                log ERROR "Instance $id is terminating"
                ;;
            terminated)
                log ERROR "Instance $id is terminated"
                ;;
            pending)
                log INFO "Instance $id is starting"
                ;;
            *)
                echo "invalid state"
                ;;
        esac
done
}

            while true;
            do
                monitoring_cycle
                sleep 10
            done
