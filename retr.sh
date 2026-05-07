#!/bin/bash

retry(){
	local attempts=$1
	shift
	local count=1
while [[ $count -le $attempts ]]; do
    "$@" && return 0

    echo "Attempt $count failed"

    ((count++))

    sleep 2
done

return 1
}

retry 3 ls /wrongpath
