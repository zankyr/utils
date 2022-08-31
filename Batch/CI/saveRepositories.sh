#!/bin/bash

MAIN_URL=""
MAIN_URL_AUTHOR="bpm1.sempla.it:8080/author"
MAIN_URL_PUBLIC="bpm1.sempla.it"

BACKUP_HOME="$HOME/backup_${AMBIENTE}"
TIMEOUT=0
USERNAME=superuser
PASSWORD=superuser
DATE=`date '+%Y%m%d_%H%M%S'`


function selectServer() {
	echo "[selectServer] - Selezione del server da cui fare l'export"
	
	if test $LOGNAME = "bpm-author"
	then
		MAIN_URL=$MAIN_URL_AUTHOR	
	else
		MAIN_URL=$MAIN_URL_PUBLIC
	fi
	
	echo "[selectServer] - url selezionata per l'utente $LOGNAME: $MAIN_URL"
	
}

function backupRepository() {
	echo "[backupRepository] - Eseguo il backup del repository $1"
	echo "[backupRepository] - all'indirizzo $MAIN_URL"

	FILE_BACKUP=$BACKUP_HOME/$DATE.$1.xml

	echo "[backupRepository] - nome del file di backup $FILE_BACKUP"
	
	/usr/local/bin/wget --timeout=$TIMEOUT --user=$USERNAME --password=$PASSWORD -O $FILE_BACKUP "http://$MAIN_URL/.magnolia/pages/export.html?mgnlRepository=$1&mgnlPath=/&mgnlKeepVersions=false&mgnlFormat=true&ext=.xml&command=exportxml&exportxml=true"
	

	DIM=$(stat -c%s $FILE_BACKUP)
	if [ "$DIM" -lt "20000" ]
                then
                     echo "[backupRepository] - KO: L'export creato e' un file minore di 20000 bite, lo elimino"
			rm -f $FILE_BACKUP

                else
                     echo "[backupRepository] - OK: L'export creato non e' un file vuoto"
       fi
      
	echo "[backupRepository] - Fine backup del repository $1"		
}

function main {
	echo "`date '+%Y%m%d_%H%M%S'` - Inizio script backup"

	selectServer

	backupRepository "dms"
	backupRepository "data"
	backupRepository "website"
	echo "`date '+%Y%m%d_%H%M%S'` - Fine script backup"
}

main

