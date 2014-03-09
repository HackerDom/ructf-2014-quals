#!/bin/bash

BACKED_HOST=${1?no backed host}
BACKED_HOST_NAME=${2?no backed host name}
BACKED_PORT=22
BACKUP_USER=root

ADMINS='andrey.malets@gmail.com last_g@hackerdom.ru'

BACKUP_DIR=/place/ructf2014q-backups/${BACKED_HOST_NAME}
mkdir -p ${BACKUP_DIR}

CURRENT_TIME=`date +%F_%H-%M-%S`
DIRS='/etc/ /root/ /home/ /var/lib/iptables/ /var/log/ /var/www/'
#EXCLUDE="/etc/fstab /etc/mtab"
FILE_HEADER=${BACKED_HOST_NAME}_${CURRENT_TIME}

#KEEP_DAYS=7
#REGEX=${BACKED_HOST}_.*

BACKUP_FILE=${BACKUP_DIR}/${FILE_HEADER}_backup.tar.gz
PKG_LIST_FILE=${BACKUP_DIR}/${FILE_HEADER}_pkg-list

umask 77

output=$((
     set -e
     PKG_LIST=$(ssh ${BACKUP_USER}@${BACKED_HOST} -p${BACKED_PORT} \
        "aptitude search ~i\!~M -F %p --disable-columns | tr '\n' ' '")
     echo ${PKG_LIST} > ${PKG_LIST_FILE} 2>&1

     set +e
     ssh ${BACKUP_USER}@${BACKED_HOST} -p${BACKED_PORT} \
        "tar czf - \$(ls -d $DIRS 2>/dev/null)" 2>&1 > ${BACKUP_FILE}
     result=$?
     if [ $result -eq 0 ] || [ $result -eq 1 ]; then exit 0; else exit 1; fi
  ) 2>&1
)

if [ $? -eq 0 ]; then
  size=`du -sh ${BACKUP_FILE} | cut -f1`
  pkgs=`wc -w ${PKG_LIST_FILE} | cut -f1 -d' '`
  /usr/sbin/send_nsca -H 194.226.244.126 -d , <<END
${BACKED_HOST_NAME},backup,0,backup ok, $size, $pkgs pkgs
END
else
  echo $output | tr -d '\015' | mail -s "${BACKED_HOST_NAME} backup FAILED" $ADMINS
  /usr/sbin/send_nsca -H 194.226.244.126 -d , <<END
${BACKED_HOST_NAME},backup,2,backup FAILED: $output
END
fi
