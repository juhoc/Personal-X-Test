#!/bin/bash

MD=$1
VGNAME=$2
SZDISK=$3
if [ -z "$MD"  ]
then
        echo "La variable <antes/despues> esta vacia"
        echo "Ejemplo: ./escanear_disco.sh antes"
        exit
fi

if [ "$MD" = "antes" ]
then
        #Elimina el temporal en caso de existir y crea un archivo con la salida del comando lsblk
        rm -f /tmp/lsblk_antes.txt
        lsblk > /tmp/lsblk_antes.txt
elif [ "$MD" = "despues" ]
then
        if [ -z "$SZDISK" ]
        then
                echo "La variable <Tamaño en disco> esta vacía"
                echo "Ejemplo: ./escanear_disco.sh despues VGAPPS 50"
        else
                #Escanear para mostrar el nuevo disco en lsblk
                for host in /sys/class/scsi_host/host*; do echo "- - -" | tee $host/scan; done
                rm -f /tmp/lsblk_despues.txt
                lsblk > /tmp/lsblk_despues.txt
                #Realiza una comparación de antes y despues para enciontrar el disco nuevo de 100G sdc por ejemplo
                DISK=$(diff /tmp/lsblk_antes.txt /tmp/lsblk_despues.txt  | grep disk | grep $SZDISK"G" |awk '{print $2}')

                echo "/dev/$DISK" > /tmp/new_disk_add.txt
                #Guarda el path del disco por ejemplo /dev/sdc
                PDISK=$(cat /tmp/new_disk_add.txt)
                #Se exiteinde el VG con el nuevo disco
                vgextend $VGNAME $PDISK
                #(command -v vgextend) $VG $PDISK
                echo "Se extendió "$VGNAME" en el nuevo disco "$PDISK""
                echo "  VG       #PV #LV #SN Attr   VSize  VFree"
                vgs | grep $VGNAME
                #$(command -v vgs) | grep $VG

        fi
else
        echo "No se reconoce la opcion $MD, debe ser 'antes' o 'despues'"
        exit
fi