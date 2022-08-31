#!/bin/bash

FILES=$(ls *.txt_fixed*)

for f in $FILES
do
	OUTPUT_FILE=$f".output"
	echo "Elaboro file $f..."
	sqlcmd -S vit82-host.domain.com -d PANDA_X_07 -U user -P password -i $f -o $OUTPUT_FILE
	
done