#!/bin/bash

if [ -f app.env ];then
        source app.env
        echo "APP.ENV FILE AVAIABLE"
else
        echo "APP.ENV IS NOT AVALAIBE"
        exit 1
fi

BACKUP="$BACKUP_FOLDER/$(date +%F_%H-%M-%S)"


info1(){
	echo "This file will helps us to"
}


while getopts ":i" opt;
do
	case $opt in 
		i)
                     info1
                     exit 1 ;;
                :)
	             echo "Option needed , invalid or empty option are not allowed"
		     ;;
     esac
done

shift $((OPTIND - 1))

Backup(){
	cp -r "$CURRENT_RUNNING" "$BACKUP"
        rm -rf "$CURRENT_RUNNING"/*
        echo "Backup Sucessfull"
}

rollback(){
  rm -rf "$CURRENT_RUNNING"/*
  cp -r "$BACKUP"/* "$CURRENT_RUNNING"/
}

Deply_Latest(){
        cp -r "$VERSIONS"/"$1"/* "$CURRENT_RUNNING"/
	echo "Deployment Sucessfull of latest version $1"
}

if [ -d  /home/bhuvaneshp3/awstutor/WebServerHealth/Deployment/"$1" ];then
	  Backup  
	  Deply_Latest $1
          
          if curl -s http://localhost:80  >/dev/null;then
              echo "Deployment Sucessfull of latest version $1"
         else
              rollback
          fi
else
 echo "the mentioned version is not available"
fi


