#!/bin/bash

FILES=$(ls *.txt*)

for f in $FILES
do
	echo "Elaboro file $f..."
	NAME=$f"_fixed"
	tr < $f -d '\000'> $NAME
done