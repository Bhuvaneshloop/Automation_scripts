#!/bin/bash

LOGS=/home/bhuvaneshp3/automations-scripts/app/logs/generatedlogs.logs

while true
do
	echo "$(date '+%Y-%m-%d %H:%M:%S') INFO USER LOGIN SUCESSFULL" >> "$LOGS"
	echo "$(date '+%Y-%m-%d %H:%M:%S') WARN API SLOW RESPONSE" >> "$LOGS"
	echo "$(date '+%Y-%m-%d %H:%M:%S') WARN API SLOW RESPONSE" >> "$LOGS"
	sleep 1
done
