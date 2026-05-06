#!/bin/bash
#set -e
#set -eoux pipefail

usage(){
    echo "1. $0  [option]"
    echo "2. List - list all instances and its statu "
    echo "3. Create [count] - creat ethe instances based o the count provided"
    echo "4. Start [instance] [][] - start the single or multiple instances"
    echo "5. Stop [instance] [][] -stop the single instance or multimple"
    echo "6. Terminate [instance] [][] - terminate the single instance or multiple instance"
    echo "7. Status [instance] - chech the status of the instance by providing the instance id"
    exit 1
}

while getopts ":h" opt;
do
    case $opt in
        h)
            usage ;;
    esac
done

ACTION=$1
shift
LOG_FILE="ec2_manager.log"
LOG_LEVEL="INFO"
count_validation(){
    if [[ "$1" =~ ^[0-9]+$ ]];
    then
        echo "valid count"
    else
        echo "not a valid count"
        exit 1
    fi
}

if [[ "$ACTION" == "create" ]];
then
    COUNT=$1
    count_validation "$COUNT"
else
    INSTANCE_ID=("$@")
fi

log() {
   # echo "$(date) : $1" | tee -a "$LOG_FILE"
   local LEVEL=$1
   shift
   local MESSAGE="$*"
   local datetime
   datetime=$(date "+%y-%m-%d %H:%M:%S")

   if [[ "$LEVEL" == "ERROR" ]];
   then
	   echo " $datetime [$LEVEL] $MESSAGE " | tee -a "$LOG_FILE" >&2
	   exit 1
   elif [[ "$LEVEL" == "DEBUG" && "$LOG_LEVEL" != "DEBUG" ]];
   then
	   return
   else
	   echo " $datetime [$LEVEL] $MESSAGE "  | tee -a "$LOG_FILE" 
   fi
}

validate_instance(){
    aws ec2 describe-instances --instance-ids "$1"  >>/dev/null 2>&1

    if [ $? -ne 0 ];
    then
        echo " ERROR : $1 is not a valid id "
	log ERROR "ERROR : $1 is not a valid id"
        exit 1
    fi
}

case $ACTION in
    list)
        log INFO "LISTING INSTANCES"
        LIST=$(aws ec2 describe-instances \
                --query "Reservations[].Instances[].{ID:InstanceId,STATE:State.Name}" \
            --output table)
	    echo "$LIST"
            log DEBUG "$LIST"
            echo $INSTANCE_ID
            ;;
        create)
            log  INFO "Creating ec2 instance"
            count_validation $COUNT
            INSTANCE_ID=$(aws ec2 run-instances \
                    --image-id ami-0e12ffc2dd465f6e4 \
                    --instance-type t3.micro \
                    --count $COUNT \
                    --query "Instances[].InstanceId" \
                --output text)
                log INFO "Created instance: $INSTANCE_ID"
                ;;
            start)
                echo "$#"
                if [ "$#" -le 1 ];
                then
                    echo "instance not specfied"
		    log ERROR "instance not specfied"
                    exit 1
                fi
                for ID in "${INSTANCE_ID[@]}";
                do
                    validate_instance $ID
                    log  INFO "Starting the instance $ID"
                    STATUS=$(aws ec2 start-instances  --instance-ids $ID)
                    log INFO  "$ID STARTED"
                done
                ;;
            stop)
                log INFO "Stoping the instance"
                for id in "${INSTANCE_ID[@]}";
                do
                    validate_instance $id
                    STATUS=$(aws ec2 stop-instances --instance-ids $id)
                    log INFO "$id Stoped"
                done
                ;;
            terminate)
                log INFO "Terminating the instance $INSTANCE_ID"
                validate_instance $INSTANCE_ID
                STATUS=$(aws ec2 terminate-instances --instance-ids $INSTANCE_ID)
                log INFO "TERMINATED $INSTANCE_ID"
                ;;
            terminate_all)
                log INFO "Sarted terminating the instances which are stoped"
                ALL=$(aws ec2 describe-instances \
                        --filters "Name=instance-state-name,Values=stopped" \
                        --query "Reservations[].Instances[].InstanceId" \
                    --output text)

                    if [ -z "$ALL" ];
                    then
                        echo "no instances in stoped state"
			log ERROR "no instances in stoped state"
                        exit 1
                    fi

                    aws ec2 terminate-instances --instance-ids $ALL >>/dev/null

                    log INFO "Terminating the instances $ALL"
                    ;;

                status)
                    log INFO "Status of the instance $INSTANCE_ID"
                    validate_instance $INSTANCE_ID
                    STATUS=$(aws ec2 describe-instances \
                            --instance-ids $INSTANCE_ID \
                            --query "Reservations[].Instances[].State.Name" \
                        --output text )
                        log INFO "instance status $STATUS"
                        ;;
                    stop_all)
                        log INFO "Started Stoping all running instances"
                        ALL=$(aws ec2 describe-instances \
                                --filters "Name=instance-state-name,Values=running" \
                                --query "Reservations[].Instances[].InstanceId" \
                            --output text)
                            if [ -z "$ALL" ];
                            then
                                echo "no instance running"
                                exit 1
                            fi
                            aws ec2 stop-instances --instance-ids $ALL >>/dev/null
                            log INFO "stoped instances $ALL"
                            ;;

                        *)
                            echo "invalid section"
			    log ERROR "invalid section"
                            exit 1
                            ;;
                    esac

