#!/bin/bash

DFINFO=$(df -HT | egrep -v "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort)
FSNAME=$1

LVINFO=$(echo "$DFINFO" | grep -wi $FSNAME | wc -l)

#Informacion individual comando "df"
if [ $LVINFO -ne 0 ]; then
echo "$DFINFO" | grep -wi $FSNAME
else
echo "No existe el Filesystem $FSNAME, favor de validar correctamente como ingreso el nombre"
fi
