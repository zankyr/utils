#!/bin/bash

SOURCE_HOME=/root/CI/source

LOGS_HOME=/root/CI/logs
LOG_TIMESTAMP=`date '+%Y%m%d_%H%M%S'`
LOG_FILE=bpm-pcc-CI-${LOG_TIMESTAMP}.log

BUILD_HOME=${SOURCE_HOME}/current/bpm

MAIL_ADDRESS="riccardo.zanchi@gft.com stefano.fumagalli@gft.com"
MAIL_SUBJECT="${HOSTNAME} - Errore CI"
SVN_ADDRESS="https://svnfir.gft.com/svn/BANK/BPM/BPM-PCC/CODICE/current"

DEPLOY_USERS[0]="bpm-author"
DEPLOY_USERS[1]="bpm-public"

PROJECT_NAME="bpm-pcc-webapp"

function selectSVN {
	echo "[selectSVN] - Selezione dell'svn:"
		SVN_ADDRESS=$SVN_ADDRESS
	echo "[selectSVN] - Svn selezionato: $SVN_ADDRESS"
}

function clean_deploy_dir {
	echo "[clean_deploy_dir] - pulizia cartelle di deploy"
    for user in ${DEPLOY_USERS[*]}
	do
		echo "[clean_deploy_dir] - Pulizia dei war nella cartella /home/${user}/CI/"
       	rm -rf  /home/${user}/CI/*.war
    	rm -rf  /home/${user}/CI/*.tar.gz
    done

}

function checkout_project {
	echo "[checkout_project] - Pulizia della cartella con i sorgenti"
	rm -rf ${SOURCE_HOME}/*
	echo "[checkout_project] - export del progetto"
	cd ${SOURCE_HOME}/
	svn export ${SVN_ADDRESS} >> ${LOGS_HOME}/${LOG_FILE}
	
	if [ $? -ne 0 ]
	then
		echo "[checkout_project] - errore durante l'export del progetto"
		cat ${LOGS_HOME}/${LOG_FILE} | mailx  -s "${MAIL_SUBJECT}" "${MAIL_ADDRESS}" 
		exit 1
	fi
}

function getwarfilename {
	ls -R ${BUILD_HOME}/bpm-pcc-webapp/target/${PROJECT_NAME}*.war
}

function zip_project {	
	for user in ${DEPLOY_USERS[*]}
	do
    	echo "[zip_project] - zip del progetto"
		cd ${BUILD_HOME}/
		tar -cvzf /home/${user}/CI/bpm.src.tar.gz ${BUILD_HOME}/ >> ${LOGS_HOME}/${LOG_FILE}

		if [ $? -ne 0 ]
		then
			echo "[zip_project] - errore durante lo zip del progetto"
			cat ${LOGS_HOME}/${LOG_FILE} | mailx -s "${MAIL_SUBJECT}" "${MAIL_ADDRESS}"
			exit 1
		fi
	done
}

function build_project {
	echo "[build_project] - build del progetto"
	cd ${BUILD_HOME}
	mvn package -Dmaven.test.skip=true >> ${LOGS_HOME}/${LOG_FILE}
	
	if [ $? -ne 0 ]
	then
		echo "[build_project] - errore durante la build del progetto"
		cat ${LOGS_HOME}/${LOG_FILE} | mailx -s "${MAIL_SUBJECT}" "${MAIL_ADDRESS}"
		exit 1
	fi
}

function delploy_project {
	echo "[deploy_project] - deploy del progetto"
       local WAR_NAME="`basename $(ls -R ${BUILD_HOME}/bpm-webapp/target/${PROJECT_NAME}*.war)`"
	for user in ${DEPLOY_USERS[*]}
    	do
		echo "[deploy_project] - Copio il war ${WAR_NAME} nella cartella /home/${user}/CI"
       	cp `getwarfilename`  /home/${user}/CI/${WAR_NAME}
		echo "[deploy_project] - Modifica dei permessi"
		chown ${user} /home/${user}/CI/${WAR_NAME}
		chgrp ${user} /home/${user}/CI/${WAR_NAME}
  
    	done
}

function rename_zip {
	echo "[rename_zip] - rename dello zip del codice"
    local ZIP_NAME="`basename $(ls -R /home/${user}/CI/*.war) .war`".src.tar.gz
	for user in ${DEPLOY_USERS[*]}
    do
		cd /home/${user}/CI/
		echo "[rename_zip] - rinomino il file bpm.src.tar.gz in /home/${user}/CI/${ZIP_NAME}"
		mv bpm.src.tar.gz ${ZIP_NAME}
		echo "[rename_zip] - Modifica dei permessi"
		chown ${user} /home/${user}/CI/${ZIP_NAME}
		chgrp ${user} /home/${user}/CI/${ZIP_NAME}
  
    	done
}

function main {
	echo "START SCRIPT CI"
	selectSVN

	clean_deploy_dir
	checkout_project
	zip_project
	build_project
	delploy_project
	rename_zip 
    echo "END SCRIPT CI"
}

main
