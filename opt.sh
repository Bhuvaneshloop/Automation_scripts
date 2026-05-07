#!/bin/bash

while getopts ":n:a:" opt;
do
	case "$opt" in 
		n) 
			Name="$OPTARG"
			;;
		a)
			Age="$OPTARG"
			;;

	        \?)
			echo "INVALID OPTIONS : -$OPTARG"
			exit 1
			;;
		:)
			echo "Option -$OPTARG  required arguments"
			exit 1
			;;
	esac
done

echo "$Name"
echo "$Age"
