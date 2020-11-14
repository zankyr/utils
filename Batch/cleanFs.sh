#/bin/bash


usage()
{
cat << EOF
usage: $0 options

Esegue la cancellazione di file e cartelle piu' vecchie dei giorni specificati
ricorsivamente nel path specificato

OPTIONS:
   -d      giorni - i file/cartelle piu' vecchi dei giorni indicati verranno rimossi

   -f	    path della cartella da pulire ricorsivamente

   -t	    lancio script in modalita' test (nessun file/cartella cancellata	

   -h	    Help
EOF
}


IS_TEST=0
while getopts “td:f:” OPTION
do
     case $OPTION in
         d)
             DAYS_OLD=$OPTARG
             ;;
         f)
             PATH_TO_CLEAN=$OPTARG
             ;;
	  t)
	      IS_TEST=1
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


if [ ! -d "$PATH_TO_CLEAN" ]; then
	echo "Il path $PATH_TO_CLEAN non esiste!"
  	usage
	exit
fi

if [ $IS_TEST == "1" ]; then
	echo "*********************************************************************"
	echo " SCRIPT IN MODALITA' TEST: NESSUN FILE O CARTELLA VERRA' CANCELLATA!"
	echo "*********************************************************************"
fi

TIMESTAMP=`date +%Y:%m:%d`

echo "`date '+%Y%m%d_%H%M%S'` - Inizio pulizia della cartella $PATH_TO_CLEAN"

echo "Cerco i file piu' vecchi di $DAYS_OLD giorno/i in $PATH_TO_CLEAN" 
find $PATH_TO_CLEAN -type f -mtime +$DAYS_OLD 
if [ $IS_TEST == "0" ]; then
	find $PATH_TO_CLEAN -type f -mtime +$DAYS_OLD -exec rm -f {} \;
fi
echo "Deleted found files"

echo "Cerco le cartelle vuote in $PATH_TO_CLEAN"
find $PATH_TO_CLEAN -type d -empty
if [ $IS_TEST == "0" ]; then
	find $PATH_TO_CLEAN -type d -empty -exec rm -rf {} \;
fi

echo "`date '+%Y%m%d_%H%M%S'` - Pulizia completata"

