#!/bin/bash

. /opt/common-bin/common-function.sh
. /opt/common-bin/common-variable.sh

usage()
{
cat << EOF
usage: $0 options

Script che esegue il deploy dell'applicazione OC: webapp e batch
a partire dal war

OPTIONS:
   -w      Deploy della webapp

   -b	    Deploy del batch

   -f	    Nome del file war

   -h	    Help
EOF
}

IS_DEPLOY_WEBAPP=0
IS_DEPLOY_BATCH=0
WAR_FILE=
while getopts “hwbf:” OPTION
do
     case $OPTION in
         w)
             IS_DEPLOY_WEBAPP=1
             ;;
         b)
             IS_DEPLOY_BATCH=1
             ;;
	  f)
	      WAR_FILE=$OPTARG
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

if [ -z $WAR_FILE ]
then
	usage
	exit
fi


echo
echo "*************************************"
echo 	"Inizio il deploy del war: $WAR_FILE"
echo "*************************************"
echo


#Backup del rilascio precedente:

if [ $IS_DEPLOY_WEBAPP == "1" ]
then
	echo INIZIO - Backup e deploy della webapp

	BACKUP_DIR="$HOME_DIR/release"
	WEBAPP_DIR="$HOME_DIR/www/webapps"
	
	backup "$WEBAPP_DIR/$WEBAPP_SUFFIX" $BACKUP_DIR 
	deploywebapp $WAR_FILE $WEBAPP_DIR/$WEBAPP_SUFFIX

	echo FINE - Backup e deploy
	echo
fi

echo
echo "*************************************"
echo    "Fine"
echo "*************************************"
echo

