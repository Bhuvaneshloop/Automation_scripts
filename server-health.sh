#!/bin/bash

#version:01
#Automating the machine health 

LOGFILE="logs/health-$(date +%F-%H-%M).log"
#
mkdir -p logs
#
echo "=== SERVER HEALTH REPORT ===" > $LOGFILE
echo "Generated on: $(date)" >> $LOGFILE
#
echo -e "\n1) Disk Usage:" >> $LOGFILE
df -h >> $LOGFILE
#
echo -e "\n2) Memory Usage:" >> $LOGFILE
free -h >> $LOGFILE

echo -e "\n3) Top 5 directories consuming the most space:" >> $LOGFILE
sudo du -sh /home/bhuvaneshp3/* 2>/dev/null | sort -hr | head -n 5 >> $LOGFILE
#
echo -e "\nReport saved to: $LOGFILE"

