#!/bin/bash
set -a
source app.env
set +a
info1(){
	echo "This file will helps us to"
}

while getopts ":i" opt;
do
	case $opt in 
		i)
                     info1 ;;
                :)
	             echo "Option needed , invalid or empty option are not allowed"
		     ;;
     esac
     shift
done
 
if [ -f app.env ];then
	echo "APP.ENV FILE AVAIABLE"
else
	echo "APP.ENV IS NOT AVALAIBE"
	exit 1
fi

Backup(){
	cp -r $CURRENT_RUNNING $BACKUP_FOLDER/$(date +%F_%H:%M:%S)
        echo "Backup Sucessfull"	
}

Deply_Latest(){
        cp -r $VERSIONS/$1/* $CURRENT_RUNNING/
	echo "Deployment Sucessfull of latest version $1"
}
case $1 in 
	V1)

	  Backup  
	  Deply_Latest $1
	  ;;
	V2)
	  Backup
	  Deply_Latest $1 
	  ;;
	*)
	  echo "Version not Available either empty"
	  ;;
esac 





