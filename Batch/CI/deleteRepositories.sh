#!/bin/bash

MAGNOLIA_DIR=${HOME}/www/magnoliaDir


function delete_db {
	echo "[delete_db] - Cancellazione db"
	mysqladmin -u${DB_USERNAME} -p${DB_PASSWORD} -f drop ${DB_NAME}
	
	if [ $? -ne 0 ]
	then
		echo "[delete_db] - errore durante la Cancellazione db"
		exit 1
	fi
}

function create_db {
	echo "[create_db] - Creazione db"
	mysqladmin -u${DB_USERNAME} -p${DB_PASSWORD} create ${DB_NAME}
	
	if [ $? -ne 0 ]
	then
		echo "[create_db] - errore durante la creazione db"
		exit 1
	fi
}

function delete_fs {
	echo "[delete_fs] - Cancellazione fs"
	#rm -rf ${MAGNOLIA_DIR}/repositories/*
	#rm -rf ${MAGNOLIA_DIR}/logs/*
	#rm -rf ${MAGNOLIA_DIR}/tmp/*
	#rm -rf ${MAGNOLIA_DIR}/cache/*
	rm -rf ${MAGNOLIA_DIR}/*
}

function main {
	echo "Avvio script di pulizia"
	delete_db
	delete_fs
	create_db
	echo "Fine script di pulizia"
}

main



