#!/bin/bash

BACKED_HOST=172.16.16.11
BACKED_HOST_NAME=qserver
BACKED_DB=qoala
BACKED_PORT=22
BACKUP_USER=root


ADMINS='andrey.malets@gmail.com last_g@hackerdom.ru'

BACKUP_DIR=/place/ructf2014q-backups/${BACKED_HOST_NAME}
mkdir -p ${BACKUP_DIR}

CURRENT_TIME=`date +%F_%H-%M-%S`

FILE_HEADER=${BACKED_HOST_NAME}_${CURRENT_TIME}
BACKUP_FILE=${BACKUP_DIR}/${FILE_HEADER}_db-backup

umask 77

output=$((
    ssh ${BACKUP_USER}@${BACKED_HOST} \
      "cd /; su postgres -c 'pg_dump $BACKED_DB -Fc'" > $BACKUP_FILE
    exit $?
  ) 2>&1
)
status=$?

if [ "$status" -ne 0 ]; then
  echo $output | mail -s "${BACKED_HOST_NAME} db backup FAILED" $ADMINS
fi
