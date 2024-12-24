#!/bin/bash
#--- Inicio validacion Salud OS
TIME=$(date +'%a-%b-%e %H:%M')
IPS=$(ip -o -4 addr | tr " " "," | sed 's/,,,,/,/g;s/inet,//g;s/:,/:/g' | cut -d: -f2 | cut -d'/' -f1)
OSPF=$(cat /etc/*release | grep ^ID= | cut -d= -f2 | tr -d "\"")
UPSN=$(if [ "$OSPF" = "sles" ]; then uptime; else uptime -s; fi)
UPPF=$(if [ "$OSPF" = "sles" ]; then uptime; else uptime -p; fi)
CPUMEM=$(top | head -5)
STSFW=$(firewall-cmd 2>/dev/null --state)
VALFW=$(if [ "$STSFW" = "running" ]; then echo "$STSFW"; else echo "not running"; fi)
IPTBL=$(iptables -n -L -v)
FSNM=$(df -hT | egrep -v "Filesystem|#|tmpfs|boot" | sed 's/ \+/,/g;s/\/dev\///g;s/mapper\///g;s/-/,/g' | tr -d "\t" | sort)
FSC=$(df -hT | egrep -v "Filesystem|#|tmpfs|boot" | wc -l)
OSRL=$(cat /etc/*release | egrep -w "^ID=|^VERSION_ID|^PRETTY_NAME" | sort)

for i in foto_salud_servidor_previa.txt
do
	touch /var/opt/ansible/$i
done

echo "-------------------------------------------" > /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Informacion de salud del SSOO" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Fecha: $TIME" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Hostname: $(hostname)" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Direcciones IPs:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "$IPS" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
if [ "$OSPF" = "rhel" ]
then
	echo "Ultimo arranque de Sistema Operativo:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
	echo "$UPSN" >> /var/opt/ansible/foto_salud_servidor_previa.txt
	echo "$UPPF" >> /var/opt/ansible/foto_salud_servidor_previa.txt
	echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
else
	echo "Ultimo arranque de Sistema Operativo:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
	echo "$UPSN" >> /var/opt/ansible/foto_salud_servidor_previa.txt
	echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
fi
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Uso de CPU y Memoria:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "$CPUMEM" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Estado del firewall:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "$VALFW" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "$IPTBL" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Estado del FileSystems:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "VGS,LV,Tipo,Tamaño,T.Utilizado,T.Disponible,% de Uso,Montura" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "$FSNM" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Numero de Filesystems: $FSC" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "Versión de sistema operativo:" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "$OSRL" >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo " " >> /var/opt/ansible/foto_salud_servidor_previa.txt
echo "-------------------------------------------" >> /var/opt/ansible/foto_salud_servidor_previa.txt

for i in foto_salud_servidor_previa.txt
do
	chown bvmuxat2:automate /var/opt/ansible/$i
	chmod 644 /var/opt/ansible/$i
done
