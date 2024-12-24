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


#Comprobar contenido de las variables
if [ -z "$FS" ]
        then
        echo "ERROR"
        echo "La variable <Filesystem> esta vacia"
        echo "Sintaxis: ./incrementar_fs.sh <Filesystem> <Tamaño en GB> <agregar o total>"
        echo "Ejemplo: ./incrementar_fs.sh /filesystem 5 total"
        exit
fi
if [ -z "$SZFS" ]
        then
        echo "ERROR"
        echo "La variable  <Tamaño FS total despues de incrementar en GB> esta vacia"
        echo "Sintaxis: ./incrementar_fs.sh <Filesystem> <Tamaño en GB> <agregar o total>"
        echo "Ejemplo: ./incrementar_fs.sh /filesystem 5 total"
        exit
fi
if [ -z "$ADD_TL" ]
        then
        echo "ERROR"
        echo "La variable  <Modo debe ser agregar o total> esta vacia"
        echo "Sintaxis: ./incrementar_fs.sh <Filesystem> <Tamaño en GB> <agregar o total>"
        echo "Ejemplo: ./incrementar_fs.sh /filesystem 5 total"
        exit
fi
#Extender LV
if [ "$ADD_TL" == "agregar" ]; then
        echo "El modo es agregar"
        MOD="que se debe agregar"
        lvextend -L+"$SZFS"G  $LVM
        if [ $? -eq 0 ]; then    echo "OK"; else    echo "ERROR"; fi

elif [ "$ADD_TL" == "total" ]; then
        echo "El modo es total"
        MOD="total que se debe tener al final"
        lvextend -L"$SZFS"G  $LVM
        if [ $? -eq 0 ]; then    echo "OK"; else    echo "ERROR"; fi
fi

#Extender el LV
#lvextend -L"$SZFS"G  $LVM



#extender el FS
if [ "$FORMAT" == "xfs" ]; then
    echo "El formato es xfs"
    xfs_growfs $FS
        if [ $? -eq 0 ]; then    echo "OK"; else    echo "ERROR"; fi

elif [ "$FORMAT" == "ext4" ]; then
    echo "El formato es ext4"
    resize2fs $LVM
        if [ $? -eq 0 ]; then    echo "OK"; else    echo "ERROR"; fi

elif [ "$FORMAT" == "ext3" ]; then
    echo "El formato es ext3"
    resize2fs $LVM
        if [ $? -eq 0 ]; then    echo "OK"; else    echo "ERROR"; fi

elif [ "$FORMAT" == "ext2" ]; then
    echo "El formato es ext2"
    resize2fs $LVM
        if [ $? -eq 0 ]; then    echo "OK"; else    echo "ERROR"; fi
fi


LVM=$(df -Th $FS | grep $FS| awk '{print $1}')
FORMAT=$(df -Th $FS  | grep $FS| awk '{print $2}')
SZFSAC=$(df -Th $FS  | grep $FS| awk '{print $3}')
echo "###############################################"
echo "Despues del incremento"
echo "Filesystem: "$FS
echo "Tamaño $MOD (en GB): "$SZFS
echo "LVM a incrementar: "$LVM
echo "Tamaño actual del FS: "$SZFSAC
