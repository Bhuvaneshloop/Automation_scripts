#!/bin/bash

#######################################
#Linux User Mnagement Script
#######################################


if [[ $EUID -ne 0 ]]; then
   echo "the user is not root"
   exit 1
fi

read -p "enter the username : " user
read -p "enter the groupname : " group


if [[ -z $user || -z $group ]]; then
   echo "the user name or group name  cant be empty"
   exit 1
fi

if getent group $group > /dev/null; then
	echo "$group already exist"
else 
	groupadd "$group" 
	echo "created the group $group sucessfully"
fi

if id $user &>/dev/null; then
	echo "$user exist already"
else 
	useradd -m -g "$group" "$user"
	echo "$user added to the group $group sucessfully"
fi
HOME="home/&user"
if [ -d  $HOME ];then
	chmod 750 "$HOME"
	chown "$user":"$group" "$HOME"
	echo "permission granted sucessfully"
fi


