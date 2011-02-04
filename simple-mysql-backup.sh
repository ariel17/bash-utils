#!/bin/bash

#
# This is a simple backup script to generate another one that helps making the 
# real work dumping the content of each valid database (by name) on each MySQL 
# server specified. Uses mysqlshow to list all existent databases and mysqldump
# to transfer the content into a file.
# The only restriction on this application is there must exists the same user 
# and password for login on each sever and at least must have SELECT grant.
#

MYSQL=/usr/bin/mysql
MYSQLSHOW=/usr/bin/mysqlshow
MYSQLDUMP="/usr/bin/mysqldump -e -q -R --compress --create-options --comments"
AWK=/usr/bin/awk
HOSTS="localhost
192.168.23.1"
USERNAME="root"
PASSWORD=""
DEST=/tmp
COMMAND=$DEST/simple-backup.sh
DATE=`/bin/date +%F`
IGNORE="databases
temp
test
information_schema"

echo ">> Simple MySQL Backup initialized.";

if [ -a $COMMAND ]; then
    /bin/rm $COMMAND;
    echo "Removed old collector script.";
fi;    

echo "Making a new collector script...";
for host in $HOSTS; do
    CONN="-u $USERNAME -h $host"
    if [ "$PASSWORD" != "" ]; then
        CONN="$CONN -p$PASSWORD"
    fi;
    for db in `$MYSQLSHOW $CONN | $AWK '{ print $2 }'`; do
        must_ignore=0
        for ignore in $IGNORE; do
            typeset -l test_ignore=$ignore;
            typeset -l test_db=$db;
            if [ $test_ignore == $test_db ]; then
                must_ignore=1;
                break;
            fi;
        done;
        if [ $must_ignore == 0 ]; then
            echo "$MYSQLDUMP $CONN $db > $DEST/$db@$host-$DATE.sql;" >> $COMMAND;
        fi;
    done;
done;

echo "Done. Now executing...";

if [ ! -a $COMMAND ]; then
    echo "** Collector file does not exist. Abort.";
    exit 1;
fi;

/bin/chmod +x $COMMAND;
exec $COMMAND;

echo "Done. Now compresing...";

/bin/gzip $DEST/*.sql;

echo "Done.";
echo ">> Finished.";

exit 0
