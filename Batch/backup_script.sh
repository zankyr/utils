#!/bin/bash

MAIL_ADDRESS="stefano.rocca@gft.it stefano.fumagalli@gft.it riccardo.zanchi@gft.com"
MAIL_SUBJECT="${HOSTNAME} - Errore nella creazione del backup"

DB_PASSWORD="bpm"

# Formato data per file
DATE=$(date +%Y-%m-%d)


FLUSSI_DIR=/home/bpm-author/flussi
BACKUP_DIR=/var/www/backup
BACKUP_DB_DIR=$BACKUP_DIR/bpm-db-dump
BACKUP_FILE=$DATE.bz2

LOG_FILE=$BACKUP_DIR/backup_$DATE.log


function init {
    echo
    echo "*************************************"
    echo    "$(date)"
    echo "*************************************"
    echo
}

# Es. stopTomcat bpm-author
function stopTomcat {
    echo "$(date) - [tomcat] Fermo Tomcat per l'utente $1..."
    sudo -u $1  /opt/common-bin/stopTomcat.sh
}

# Es. startTomcat bpm-author
function startTomcat {
    echo "[tomcat] Riavvio Tomcat per l'utente $1..."
    sudo -u $1 /opt/common-bin/startTomcat.sh
}

# Esegue il backup della cartella in input salvando un archivio .bz2 nella cartella di backup
# Es: backup /home/user/app/
function backup {
    if [ -d "$1" ]; then
        echo "[backup_flussi] Salvo il contenuto della cartella $1 in $BACKUP_DIR/$BACKUP_FILE"
	tar cjvf $BACKUP_DIR/$BACKUP_FILE -C $1 . 1>/dev/null
    else
       echo "[backup_flussi] Cartella $1 non trovata, non effettuo backup"
    fi

}

# Backup del db
# backup_db <database> <username> <password>
# e.g. backup_db bpm_author bpm_author 12345
function backup_db {
    echo "[backup_db] - Esecuzione del backup per il db: $1"
    mysqldump --max_allowed_packet=128M --opt $1 -u $2 -p$3 > $BACKUP_DB_DIR/$DATE.$1.$AMBIENTE.sql
    

    if [ $? -ne 0 ]
    then
        echo "[backup_db] - Errore durante il backup dell'db: $1"
        cat "Errore durante il backup dell'db: $1" | mailx  -s "${MAIL_SUBJECT}" "${MAIL_ADDRESS}"
        exit 1
    fi
}


function cleanDirectory {
    if [ -d "$1" ]; then
        echo "[clean] Cancello file più vecchi di 3 giorni in $1..."
	find $1 -type f -mtime +3 -print
	find $1 -type f -mtime +3 -exec rm -f {} \;

    else
        echo "[clean] Cartella $1 non trovata, non procedo con la cancellazione"
    fi

}

# Redirigo output stderr su stdout, e stdout sul file di log
exec 1>${LOG_FILE}
exec 2>&1

init
backup $FLUSSI_DIR

stopTomcat bpm-author
stopTomcat bpm-public
sleep 15

backup_db bpm_author bpm_author bpm
backup_db bpm_public bpm_public bpm
backup_db BPM_PCC_INDICI root root 

startTomcat bpm-author
startTomcat bpm-public

cleanDirectory $BACKUP_DIR
cleanDirectory $BACKUP_DB_DIR

ls -lR | mailx -s "Backup: stato sistema" "${MAIL_ADDRESS}"
