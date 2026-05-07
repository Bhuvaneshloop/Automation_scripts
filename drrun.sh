#!/bin/bash

DRU_RUN=$1

run_cmd(){
	if "$DRU_RUN";
	then
		echo "[DRU-RUN] $*"
	else
		eval "$*"
	fi
}

run_cmd aws ec2 describe-instances \
	--output text \
        --query "Reservations[].Instances[].InstanceId"
