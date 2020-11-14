#!/bin/bash

# Formatta il timestamp per i log
function logtimestamp {
	date +"%Y-%m-%d %H:%M:%S"
}

function filetimestamp {
	date +"%Y-%m-%d-%H%M%S"
}

function filedate {
	date +"%Y-%m-%d"
}

function batchLogFileName {
	echo "batch_$1_"`filedate`".log"
}

# Esegue il backup della cartella target e salva uno zip nella cartella di backup in 
# una sottocartella con un timestamp.
# Al termine cancella il contenuto della cartella target
# Es: backup /home/user/app/ /home/user/backup
function backup {

if [ -d "$1" ]; then

	NOW=$(date +"%Y-%m-%d-%H%M%S")
	echo Creo la cartella per il backup $2/$NOW
	mkdir $2/$NOW

	echo Salvo il contenuto attuale della cartella $1 nella cartella di backup
	tar cjvf $2/$NOW/backup_$NOW.tar.bz2 -C $1 . 1>/dev/null

	echo Cancello la cartella di rilascio
	rm -rf $1
else
	echo Nessun deploy precedente trovato. Non pulisco la cartella di rilascio.
fi

}

# Recupera il nome del jar dei batch
function getjarfilename {
	basename $(ls -R $LOADER_DIR/oc-batch*)
}

# Deploy del war nella webapp
function deploywebapp {
	echo Copio il nuovo war nella webapp e lo rinomino $2.war
	cp $1 $2.war
}

# Deploy del batch
function deploybatch {
	# Se non esiste creo la directory in cui fare il deploy
	if [ ! -d "$2" ]
	then
		echo La directory $2 non esiste la creo
		mkdir $2
	fi
	local NOW=`filetimestamp`

	# Creo la directory temporanea in cui scompattare il war
	mkdir $2/temp_$NOW
	cp $1 $2/temp_$NOW

	# Scompatto il war
	cd $2/temp_$NOW
	unzip $2/temp_$NOW/$1 > /dev/null
	cd -

	# Copio tutto il contenuto della cartella lib nella directory di deploy
	# del batch
	cp $2/temp_$NOW/WEB-INF/lib/* $2

	# Rimuovo la directory temporanee
	rm -rf $2/temp_*
}
