#!/bin/bash

# Validación de parámetros
if [ $# -ne 4 ]; then
  echo "Error: Se requieren dos parámetros."
  echo "Uso: $0 <nombre_del_filesystem> <tamaño_del_filesystem><nombre_del_volume_group><nombre_del_logical_volume>"
  exit 1
fi

# Variables
FSNAME=$1
SZNFS=$2 # Cantidad de GB que quieres restar del espacio libre del VG
VGN=$3
LVN=$4

# Para validar si existe el FileSystem
INFOFS=$(df 2>/dev/null -HT | grep -wi "$FSNAME")

# Validar que exista el FS
if [[ -z "$INFOFS" ]]; then
  VG_NAME=$VGN
  LV_NAME=$LVN

  # Obtener el espacio libre en el VG en GB
  FREE_VG=$(vgs --units g --noheadings -o vg_free "$VG_NAME" | awk '{print int($1)}')

  # Calcular el espacio libre después de incrementar el LV
  REMAINING_SPACE=$(($FREE_VG - $SZNFS))

  # Validar el espacio restante
  if [ "$REMAINING_SPACE" -lt 1 ]; then
    echo "agregar_disco"
  else
    echo "crear_filesystem"
  fi
else
  echo "Existe el $FSNAME"
fi