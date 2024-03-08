#!/bin/bash

BACKUPDIR=/home/rstudio/backup

if [ -f "$BACKUPDIR"/passwd.bak ] && [ -f "$BACKUPDIR"/shadow.bak ]; then
  echo "Restoring users..."
  cat "$BACKUPDIR"/passwd.bak >> /etc/passwd
  cat "$BACKUPDIR"/shadow.bak >> /etc/shadow

  if [ -f "$BACKUPDIR"/group.bak ]; then
    cat "$BACKUPDIR"/group.bak >> /etc/group
  fi

  if [ -f "$BACKUPDIR"/staff.bak ]; then
    STAFF=`cat "$BACKUPDIR"/staff.bak | tr -d '\n'`
    STAFF="${STAFF##*:}"
    for user in ${STAFF//,/ }
    do
      echo $user
      if [ "$user" != "rstudio" ]; then
        gpasswd -a $user staff
      fi
    done
  fi
  
  echo "done"
fi
