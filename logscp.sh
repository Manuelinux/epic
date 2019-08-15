#!/bin/bash
rhost=10.6.193.0
ruser=panfilo
lpath=/var/log/httpd/
rpath=/home/panfilo/backup/log/
backup_logs=tmplogs.log
log_format=sendlogs_$(date +"%Y-%m-%d-%H-%M").log
ssh -l $ruser $rhost "ls $rpath" > $backup_logs 2>&1
for logfile in $(find $lpath -name '*_*_*.log' | cut -d '/' -f 5); do
    hour=$(echo $logfile | cut -d '_' -f 3 | cut -d '.' -f 1)    
    if [ $hour -ge 18 ]; then
        if [ $hour -le 21 ]; then
            if grep -Fxq "$logfile" $backup_logs; then
                 echo "File $logfile exists on remote server" >> $log_format
             else
                 echo "Sending $logfile to remote server" >> $log_format
                 scp $lpath/$logfile $ruser"@"$rhost:$rpath > /dev/null 2>&1 
             fi 
        fi
    fi
done
cat $log_format
