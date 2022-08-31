#!/bin/bash

# Percorso file flussi input
BASE_DIR="$HOME/flussi/IN/"
# Cartella file in ko
KO_DIR="/ko"
# Flussi in entrata
DIR_LIST=$(ls $BASE_DIR)

LOG_FILE="flussi_ko.log"

function log(){
	if [ ! -f $LOG_FILE ] ; then
		touch $LOG_FILE
	fi
	
	echo "$1 : $2" >> $LOG_FILE
}

function removeFile(){
	rm $LOG_FILE
}

function mailToSupport(){
	 less $LOG_FILE | mailx -r noreply@bricocenter.it -s "[GCM] ALERT: flussi in errore" -a $LOG_FILE supporto.brico.italy@gft.com
	 removeFile
}

for DIR in ${DIR_LIST[@]}
do
	FIND_DIR=$BASE_DIR$DIR$KO_DIR
	FILE_COUNT=$(find $FIND_DIR -type f | wc -l)

	if [ $FILE_COUNT -gt 0 ] ; then
		log $FIND_DIR $FILE_COUNT
	fi
done

if [ -f $LOG_FILE ] ; then
	mailToSupport
fi

exit

