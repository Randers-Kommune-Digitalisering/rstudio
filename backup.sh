#!/bin/bash

BACKUPDIR=/home/rstudio/backup
UGIDLIMIT=1001
mkdir -p $BACKUPDIR

chown root:root $BACKUPDIR
chmod 700 $BACKUPDIR

function backup_passwd {
    awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/passwd > "$BACKUPDIR"/passwd.bak
    echo "passwd backup done"
}

function backup_shadow {
    awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534) {print $1}' /etc/passwd | tee - | egrep -f - /etc/shadow > "$BACKUPDIR"/shadow.bak
    echo "shadow backup done"
}

function backup_group {
    awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/group > "$BACKUPDIR"/group.bak
    STAFF="$(grep '^staff' /etc/group)"
    echo  $STAFF > "$BACKUPDIR"/staff.bak
    echo "group backup done"
}

while inotifywait -e attrib /etc/passwd
do
    echo "backing up passwd"
    backup_passwd &
done &

while inotifywait -e attrib /etc/shadow
do
    echo "backing up shadow"
    backup_shadow &
done &

while inotifywait -e attrib /etc/group
do
    echo "backing up group"
    backup_group &
done

#/etc/passwd 
#inotifywait -m -q --format '%w%f' /etc/shadow /etc/group -e modify | while read FILE
#do
#    echo "Backing up $FILE.."
#    NAME==$(basename -- "$FILE")
#
#    if [[ "$FILE" == *"shadow"* ]]; then
#        awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534) {print $1}' /etc/passwd | tee - | egrep -f - $FILE > "$BACKUPDIR/$NAME".bak
#    elif [[ "$FILE" == *"group"* ]]; then
#        awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' $FILE > "$BACKUPDIR/$NAME".bak
#        #STAFF="$(grep '^staff' $FILE)"
#        #echo "${STAFF##*. }" > "$BACKUPDIR"/staff.bak
#    else
#        awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' $FILE > "$BACKUPDIR/$NAME".bak
#    fi
#    echo "done"
#done

#BACKUPDIR=/home/rstudio/backup
#UGIDLIMIT=1001
#mkdir -p $BACKUPDIR

#chown root:root $BACKUPDIR
#chmod 700 $BACKUPDIR

#awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/passwd > "$BACKUPDIR"/passwd.bak
#awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/group > "$BACKUPDIR"/group.bak
#awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534) {print $1}' /etc/passwd | tee - |egrep -f - /etc/shadow > "$BACKUPDIR"/shadow.bak