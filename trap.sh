#!/bin/bash

set -e 

message(){
echo "hi file exited"
}

trap message SIGINT

echo "started"

while true ;
do
sleep 10
echo  "helow helow"
done

echo "exited"
