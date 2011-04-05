#!/bin/bash -x

# Compress all files filtering by the indicated extension, passing by those
# generated today.

# PATH=/mnt/backupfree/nfs
PATH=/tmp
EXT="sql"
TODAY=`/bin/date +"%Y-%m-%d"`
# GZIP=/usr/bin/gzip
GZIP=/bin/gzip

cd $PATH;
for file in `/bin/ls *.$EXT`; 
do    
    if [ $file != *$TODAY* ]; then
        $GZIP $file &
    fi
done;    
