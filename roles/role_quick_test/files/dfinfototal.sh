#!/bin/bash

DFINFO=$(df -hT | egrep -v "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort)

#Informacion total de comando "df"
echo "$DFINFO"
