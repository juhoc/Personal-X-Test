#!/bin/bash

#EL FS no debe llevar '/' al final
FS=$1
SZFS=$2
ADD_TL=$3
LVM=$(df -Th $FS | grep $FS| awk '{print $1}')
FORMAT=$(df -Th $FS  | grep $FS| awk '{print $2}')
SZFSAC=$(df -Th $FS  | grep $FS| awk '{print $3}')

echo "###############################################"
echo "Antes del incremento"
echo "Filesystem: "$FS
echo "Tamaño definido en el script (GB): "$SZFS
echo "LVM a incrementar: "$LVM
echo "Tamaño actual del FS: "$SZFSAC

LVM=$(df -Th $FS | grep $FS| awk '{print $1}')
FORMAT=$(df -Th $FS  | grep $FS| awk '{print $2}')
SZFSAC=$(df -Th $FS  | grep $FS| awk '{print $3}')
echo "###############################################"
echo "Despues del incremento"
echo "Filesystem: "$FS
echo "Tamaño $MOD (en GB): "$SZFS
echo "LVM a incrementar: "$LVM
echo "Tamaño actual del FS: "$SZFSAC
