#!/bin/bash

/mount/data/bingft/bin/common-function.sh

usage()
{
cat << EOF
usage: $0 options

Script che esegue il deploy dell'applicazione OC: webapp e batch
a partire dal war

OPTIONS:
   -a      Deploy della webapp author

   -p	   Deploy della webapp public

   -b	   Deploy del batch flussi

   -h	   Help
EOF
}

IS_DEPLOY_PUBLIC=0
IS_DEPLOY_AUTHOR=0
IS_DEPLOY_BATCH=0

DEPLOY_DIR=$HOME/deploy

WAR_FILE=
JAR_FILE=
while getopts “hapb:” OPTION
do
	case $OPTION in
		a)
			IS_DEPLOY_AUTHOR=1
			WAR_FILE=($(find $DEPLOY_DIR -maxdepth 1 -type f -iname "*.war"))
            ;;
        p)
			IS_DEPLOY_PUBLIC=1
			WAR_FILE=($(find $DEPLOY_DIR -maxdepth 1 -type f -iname "*.war"))
            ;;
		b)
			IS_DEPLOY_BATCH=1
			JAR_FILE=($(find $DEPLOY_DIR -maxdepth 1 -type f -iname "*.jar"))
			;;
        h)
			usage
            exit
            ;;
        ?)
            usage
            exit
            ;;
    esac
done


#Backup del rilascio precedente:

if [ $IS_DEPLOY_AUTHOR == "1" ] ; then
	echo INIZIO - Backup e deploy webapp author
	
	if [ ${#WAR_FILE[@]} -ne 1 ] ; then
		echo "Sono stati trovati ${#WAR_FILE[@]} file per il deploy (attesi 1). Termino l'esecuzione"
		exit 1
	fi

	AUTHOR_DIR=$HOME/bpm-author
	BACKUP_DIR="$AUTHOR_DIR/release"
	WEBAPP_DIR="$AUTHOR_DIR/www/webapps"
	WEBAPP_AUTHOR_NAME=author
	
	backup "$WEBAPP_DIR/$WEBAPP_AUTHOR_NAME" $BACKUP_DIR 
	deploywebapp $WAR_FILE $WEBAPP_DIR/$WEBAPP_AUTHOR_NAME

	echo FINE - Backup e deploy webapp author
	echo
fi

if [ $IS_DEPLOY_PUBLIC == "1" ]
then
	echo INIZIO - Backup e deploy webapp public
	
	if [ ${#WAR_FILE[@]} -ne 1 ] ; then
		echo "Sono stati trovati ${#WAR_FILE[@]} file per il deploy (attesi 1). Termino l'esecuzione"
		exit 1
	fi
	
	PUBLIC_DIR=$HOME/bpm-public
	BACKUP_DIR="$PUBLIC_DIR/release"
	WEBAPP_DIR="$PUBLIC_DIR/www/webapps"
	WEBAPP_PUBLIC_NAME=ROOT
	
	backup "$WEBAPP_DIR/$WEBAPP_PUBLIC_NAME" $BACKUP_DIR 
	deploywebapp $WAR_FILE $WEBAPP_DIR/$WEBAPP_PUBLIC_NAME

	echo FINE - Backup e deploy webapp public
	echo
fi


