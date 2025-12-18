#!/bin/bash

logfile=~/automations-scripts/tar-backup/genrator/logs
backupdir=~/automations-scripts/tar-backup/backup-log
archive="$backupdir/backup-$(date +%H-%M-%S).tar"
exec >> "$logfile/tarlog%(date +%F-%H-%M-%S).log" 2>&1
tar -cvf "$archive" -C "$(dirname "$logfile")" "$(basename  "$logfile")"

if [ -f $archive &>/dev/null ]; then
	echo "backup sucessfull"
else 
	echo "backup not sucess full"
fi

find "$backupdir" -type f -mtime +7 -delete
echo "Backup completed at $(date)"

