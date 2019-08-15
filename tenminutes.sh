#!/bin/bash
actual=$(date -d "-10 minutes" +'%H%M%S')
minute=$(date +"%M")
logfile=/var/log/httpd/access_log
log_format=error_500_$(date +"%Y-%m-%d-%H-%M").log
test -e $log_format
if [ $? -eq 0 ]; then
    rm $log_format
fi
touch $log_format
grep "500 " $logfile > error500 2>&1
if [ $minute -lt 10 ]; then
    logfile=/var/log/httpd/$(date -d "-1 hour" +"%Y_%m_%d_%H").log
    test -e $logfile
    if [ $? -eq 0 ]; then
        grep "500 " $logfile >> error500 2>&1
    fi    
fi
IFS=$'\n'
for line in $(cat error500 ); do
    logdate=$(echo $line | cut -d '[' -f 2 | cut -d ' ' -f 1 | cut -d ':' -f 2-4 )
    logdate=$(date -d $logdate +'%H%M%S')
    if [ $logdate -ge $actual ]; then
        echo $line >> $log_format 2>&1
    fi
done 
cat $log_format
rm error500
