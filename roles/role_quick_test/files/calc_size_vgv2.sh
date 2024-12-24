#!/bin/bash

if [ -f /usr/bin/python ]; then
COMCAL=/usr/bin/python
elif [ -f /usr/bin/python3 ]; then
COMCAL=/usr/bin/python3
fi

if [ $# -ne 4 ]; then
  echo "Error: Se requieren 4 parámetros."
  echo "Uso: $0 <nombre_del_filesystem> <tamaño_del_filesystem> <nombre_del_VG> <nombre_del_LV>"
  exit 1
fi

FSNAME=$1
FZSIZE=$2
VGNAME=$3
LVNAME=$4

INFOFS=$(df -HT | egrep -v "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort | grep -wi $FSNAME)
NMFS=$(echo $INFOFS | cut -d, -f8)
NMLV=$(echo $INFOFS | cut -d, -f2)
SZTFS=$(echo $INFOFS | cut -d, -f4 | tr -d '[A-Z]')
SZTVG=$(vgs | grep $VGNAME | awk -F ' ' '{print $7}' | tr -d '<>[a-z]')
SZTNFS=$($COMCAL -c "print(round($SZTFS + $FZSIZE, 2))")
RFSZVG=$($COMCAL -c "print(round($SZTVG - $FZSIZE, 2))")
echo $RFSZVG > ~/valszvg.txt

echo -e "$FSNAME,$FZSIZE,$VGNAME,$LVNAME"

if [ "$FSNAME" = "$NMFS"  ] && [ "$LVNAME" = "$NMLV" ];then
  echo "existe_$FSNAME"
else
  if grep -q ^[1-9]..\... ~/valszvg.txt || grep -q ^[1-9].\... ~/valszvg.txt || grep -q ^[1-9]\... ~/valszvg.txt || grep -q ^[1-9]\.0 ~/valszvg.txt; then
    echo "crear_filesystem"
  elif grep -q ^1\.0. ~/valszvg.txt  || grep -q ^\-[1-9] ~/valszvg.txt; then
    echo "agregar_disco"
  else
  echo "agregar_dico"  
  fi
fi

echo -e "------------------------\nNombre del FS: $FSNAME\nNombre de LV: $LVNAME\nTamaño actual del FS $FSNAME: $SZTFS\nEspacio libre del VG $NMVG: $SZTVG\nIncremento de tamaño del FS $FSNAME: $FZSIZE\nNuevo tamaño del FS $FSNAME: $SZTNFS\nRestar espacio libre al VG $NMVG: $RFSZVG"
