#!/bin/bash

# Validación de parámetros
if [ $# -ne 2 ]; then
  echo "Error: Se requieren dos parámetros."
  echo "Uso: $0 <nombre_del_filesystem> <tamaño_del_filesystem>"
  exit 1
fi

# Variables
FSNAME=$1
SZNFS=$2 # Cantidad de GB que quieres restar del espacio libre del VG

# Para validar si existe el FileSystem
INFOFS=$(df -HT | egrep -v "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort | grep -wi "$FSNAME")

# Validar que exista el FS
if [[ -n "$INFOFS" ]]; then
  VG_NAME=$(echo "$INFOFS" | cut -d, -f1)
  LV_NAME=$(echo "$INFOFS" | cut -d, -f2)

  # Obtener el espacio libre en el VG en GB
  FREE_VG=$(vgs --units g --noheadings -o vg_free "$VG_NAME" | awk '{print int($1)}')

  # Calcular el espacio libre después de incrementar el LV
  REMAINING_SPACE=$(($FREE_VG - $SZNFS))

  # Validar el espacio restante
  if [ "$REMAINING_SPACE" -lt 1 ]; then
    echo "agregar_disco"
  else
    echo "incrementar_filesystem"
  fi
else
  echo "No existe el $FSNAME"
fi
