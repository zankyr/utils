# Batch
Contains several batch files used in my career.

## fix_null_value.sh
In the current directory, loops all the files with the given extension, remove all the '000' char (NUL) and create a new cleaned file.

## execute-sqlserver-scripts.sh
In the current directory, loops all the files with the given extension and execute the file as a SQLServer script, in the provided server/instance. Also, it saves the output of the execution in a dedicated file.
