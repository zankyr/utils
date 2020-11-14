#!/bin/bash

DEPLOY_DIR=${HOME}/CI
BACKUP_DIR=${HOME}/backup_${AMBIENTE}
SAMPLES_DIR=${HOME}/www/samplesDir
DATE=`date '+%Y%m%d_%H%M%S'`

WAR_NAME="`basename $(ls -R ${DEPLOY_DIR}/*.war)`"

function findLastBackup() {
	echo "[findLastBacup] - Trovo l'ultimo backup per il repository $1 nella cartella $BACKUP_DIR"
	
	local REGEX="$1.xml"
	LAST_BACKUP=`find $BACKUP_DIR/ -maxdepth 1 -name \*$REGEX -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" " | sed 's_.*/__'`	
	
	if [ -f "$BACKUP_DIR/$LAST_BACKUP" ]; then
		echo "[findLastBacup] - Ultimo backup trovato: $LAST_BACKUP"
	
		echo "[findLastBacup] - Rimuovo il vecchio backup nella cartella $SAMPLES_DIR"

		rm -rf $SAMPLES_DIR/*$1.xml

		echo "[findLastBacup] - Sposto l'ultimo backup nella cartella $SAMPLES_DIR"
		cp $BACKUP_DIR/$LAST_BACKUP $SAMPLES_DIR/$1.xml
	else
		echo "[findLastBacup] - Non e' stato trovato un backup: nessuna azione"
	fi
	
	echo "[findLastBacup] - Fine"
}

echo "********************************************************************"
echo "`date '+%Y%m%d_%H%M%S'` - Inizio processo di rigenerazione ambiente"
echo "********************************************************************"


if [ "${WAR_NAME}" ]; then

	/opt/common-bin/CI/saveRepositories.sh
	/opt/common-bin/stopTomcat.sh
	/opt/common-bin/CI/deleteRepositories.sh
	/opt/common-bin/deploy.sh -wf ${DEPLOY_DIR}/${WAR_NAME}

	findLastBackup "dms"
	findLastBackup "data"
	findLastBackup "website"
	
	/opt/common-bin/startTomcat.sh
else
	echo "Nessun war da rilasciare!"
fi

echo "********************************************************************"
echo "`date '+%Y%m%d_%H%M%S'` - Fine processo di rigenerazione ambiente"
echo "Per completare il processo e' necessario importare il content"
echo "salvato nella cartella $SAMPLES_DIR"
echo "********************************************************************"
