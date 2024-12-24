#!/bin/bash

if [ -f /usr/bin/python ]; then
COMCAL=/usr/bin/python
elif [ -f /usr/bin/python3 ]; then
COMCAL=/usr/bin/python3
fi

if [ $# -ne 2 ]; then
  echo "Error: Se requieren dos parámetros."
  echo "Uso: $0 <nombre_del_filesystem> <tamaño_del_filesystem>"
  exit 1
fi

FSNAME=$1
SZNFS=$2
INFOFSC=$(df -HT | egrep -v "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort | grep -wi $FSNAME | wc -l)

if [ $INFOFSC -eq 1 ]; then

  INFOFS=$(df -HT | egrep -v "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort | grep -wi $FSNAME)
  NMVG=$(echo $INFOFS | cut -d, -f1)
  NMLV=$(echo $INFOFS | cut -d, -f2)
  SZOTFS=$(echo $INFOFS | cut -d, -f4 | tr -d '[A-Z]')
  FSZVG=$(vgs "$NMVG" | tail -1 | awk -F ' ' '{print $7}' | tr -d '[a-z]<')
  SZTNFS=$($COMCAL -c "print(round($SZOTFS + $SZNFS, 2))")
  RFSZVG=$($COMCAL -c "print(round($FSZVG - $SZNFS, 2))")
  echo $RFSZVG > ~/valszfs.txt

  echo -e "$FSNAME,$NMVG,$NMLV,$SZOTFS,$FSZVG,$SZNFS,$SZTNFS,$RFSZVG"

    if grep -q ^1\.0. ~/valszfs.txt  || grep -q ^\-[1-9] ~/valszfs.txt; then
      echo "agregar_disco"
    elif grep -q ^[1-9]..\... ~/valszfs.txt || grep -q ^[1-9].\... ~/valszfs.txt || grep -q ^[1-9]\... ~/valszfs.txt || grep -q ^[1-9]\.0 ~/valszfs.txt; then
      echo "incrementar_filesystem"
    else
    echo "agregar_disco"
    fi

    echo -e "------------------------\nNombre del FS: $FSNAME\nNombre del VG: $NMVG\nNombre de LV: $NMLV\nTamaño actual del FS $FSNAME: $SZOTFS\nEspacio libre del VG $NMVG: $FSZVG\nIncremento de tamaño del FS $FSNAME: $SZNFS\nNuevo tamaño del FS $FSNAME: $SZTNFS\nRestar espacio libre al VG $NMVG: $RFSZVG"

else
echo "No existe $FSNAME"
fi

rm -rf ~/valszfs.txt