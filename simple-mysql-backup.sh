#!/bin/bash

#
# This is a simple backup script to generate another one that helps making the 
# real work dumping the content of each valid database (by name) on each MySQL 
# server specified. Uses mysqlshow to list all existent databases and mysqldump
# to transfer the content into a file.
# The only restriction on this application is there must exists the same user 
# and password for login on each sever and at least must have SELECT, LOCK 
# TABLES and SHOW VIEW privileges.
#

MYSQL=/usr/bin/mysql
MYSQLSHOW=/usr/bin/mysqlshow
MYSQLDUMP="/usr/bin/mysqldump -e -q -R --compress --create-options --comments"
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

function log {
    echo `/bin/date` $1;
}

log ">> Simple MySQL Backup initialized.";

if [ -e $COMMAND ]; then
    /bin/rm $COMMAND;
    log "Removed old collector script.";
fi;    

log "Making a new collector script...";
for host in $HOSTS; do
    # Creates the connection string
    CONN="-u $USERNAME -h $host"

    # if password == "" the "-p" parametter is not needed.
    if [ "$PASSWORD" != "" ]; then
        CONN="$CONN -p$PASSWORD"
    fi;

    # # Will create a subdirectory per host in DEST, if it can.
    # if [ ! -e $DEST/$host ]; then                                                                               
    #     log "/bin/mkdir $DEST/$host;" >> $COMMAND;
    #     DESTDUMP=$DEST/$host;
    # elif [ -d $DEST/$host ]; then
    #     DESTDUMP=$DEST/$host;
    # else
    #     log "# Cannot create $DEST/$host because already exist and it is not a directory." >> $COMMAND;
    #     DESTDUMP=$DEST;
    # fi;

    # Itering over 'show databases()' result.
    for db in `$MYSQLSHOW $CONN | /usr/bin/awk '{ print $2 }'`; do
        must_ignore=0
        for ignore in $IGNORE; do
            test_ignore=`echo $ignore | /usr/bin/awk '{ print tolower($0) }'`;
            test_db=`echo $db| /usr/bin/awk '{ print tolower($0) }'`;
            if [ $test_ignore == $test_db ]; then
                must_ignore=1;
                break;
            fi;
        done;

        if [ $must_ignore == 1 ]; then
            # Continue to the next db if must ignore this one.
            continue;
        fi;

        echo "echo `/bin/date` 'Dumping $db@$host...';" >> $COMMAND;
        # echo "$MYSQLDUMP $CONN $db > $DESTDUMP/$db@$host-$DATE.sql;" >> $COMMAND;
        echo "$MYSQLDUMP $CONN $db > $DEST/$db@$host-$DATE.sql;" >> $COMMAND;
        echo "echo `/bin/date` 'Done.';" >> $COMMAND;

    done;
done;

log "Done. Now executing:";

if [ ! -e $COMMAND ]; then
    log "** Collector file does not exist. Abort.";
    exit 1;
fi;

/bin/chmod +x $COMMAND;
$COMMAND;

log "Done. Now compressing all files...";

# Compress all resulting files.
/bin/gzip $DEST/*.sql;

log "Done.";
log ">> Finished.";

exit 0
