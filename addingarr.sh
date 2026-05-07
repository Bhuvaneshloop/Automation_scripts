#!/bin/bash

ids=()

while getopts ":i:" opt;
do
	case $opt in
		i)
			ids+=("$OPTARG")
			;;
	esac
done

for id in "${ids[@]}";
do
	echo "$id"
done 
