#!/bin/bash

# File backup content non piu' vecchi di 5gg
/opt/common-bin/cleanFs.sh -d 5 -f /home/bpm-author/backup_$AMBIENTE/
/opt/common-bin/cleanFs.sh -d 5 -f /home/bpm-public/backup_$AMBIENTE/ 

# Release on piu' vecchie di 10gg
/opt/common-bin/cleanFs.sh -d 10 -f /home/bpm-author/release/ 
/opt/common-bin/cleanFs.sh -d 10 -f /home/bpm-public/release/

# File backup content non piu' vecchi di 3gg
/opt/common-bin/cleanFs.sh -d 3 -f /var/www/backup/bpm-db-dump/

# Pulizia cartelle temp
rm -rf /home/bpm-author/www/temp/*
rm -rf /home/bpm-public/www/temp/*
