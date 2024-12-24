

$vCenter=$args[0]
$VM=$args[1]
$Cluster = $args[2]
$StorageFormat = $args[3]
$DiskSize = 100

	
if ( $VM ) {}
    else
	{
		Write-Host ""
		Write-Host "Faltan parametros para la ejecucion."
		Write-Host "Sintaxis:"
		Write-Host "  .\AgregarDisco.ps1 <vCenter> <VM> <Cluster> <Thin o Thick>"
		Write-Host "  Ejemplo: .\AgregarDisco.ps1 150.100.188.84 Nombre_VM Entornos_previos_01 Thin"
		Write-Host ""
        Exit
	}

if ( $Cluster ) {}
    else
	{
		Write-Host ""
		Write-Host "Faltan parametros para la ejecucion."
		Write-Host "Sintaxis:"
		Write-Host "  .\AgregarDisco.ps1 <vCenter> <VM> <Cluster> <Thin o Thick>"
		Write-Host "  Ejemplo: .\AgregarDisco.ps1 150.100.188.84 Nombre_VM Entornos_previos_01 Thin"
		Write-Host ""
        Exit
	}
	
if ( $StorageFormat ) {}
    else
	{
		Write-Host ""
		Write-Host "Faltan parametros para la ejecucion."
		Write-Host "Sintaxis:"
		Write-Host "  .\AgregarDisco.ps1 <vCenter> <VM> <Cluster>"
		Write-Host "  Ejemplo: .\AgregarDisco.ps1 150.100.188.84 Nombre_VM Entornos_previos_01 Thin"
		Write-Host ""
        Exit
	}
	
#-- Ajustar parÃ¡metros del nombre del vCenter, el -user y -Password
#$vCenter="vcsa-01.core.hypervizor.com"
#$vcUser = "administrator@vsphere.local"
#$vcPass = "VMware1!"

#-- No modificar cadena _$time
$time = Get-Date -Format "yyyyMMdd_HHmmss"
$output_file = ".\AgregarDisco_$time.log"

if ($DiskSize -is [int]) {}
	else
	{
		Write-Host ""
		Write-Host "El parametro de DiskSize debe ser numÃ©rico."
		Write-Host "Sintaxis:"
		Write-Host "  .\AgregarDisco.ps1 <vCenter> <VM> <Cluster>"
		Write-Host "  Ejemplo: .\AgregarDisco.ps1 150.100.188.84 Nombre_VM Entornos_previos_01"
		Write-Host ""
        Exit
	}

#-- Obtiene el datastore con mas espacio del cluster
$oDatastoreWithMostFree = Get-Datastore $Cluster* | Sort-Object -Property FreespaceGB -Descending:$true | Select-Object -First 1

#Se define el valor de espacio libre minimo que debe de tener el datastore 300GB (100 GB del nuevo disco mas 200 GB  que debe tener libre)
$intNewVMDiskSize = 300

#Si el espacio libre es mayor mayor al valor de espacio libre minimo se agrega el disco, de lo contrario no se agrega
if (($oDatastoreWithMostFree.FreespaceGB ) -gt $intNewVMDiskSize)
	{write-host "Hay suficiente espacio, se agrega el nuevo disco  de '$($DiskSize)' GB  a '$($VM)' del datastore '$($oDatastoreWithMostFree.Name)' " 
	 New-HardDisk -VM $VM -CapacityGB $DiskSize -Datastore $oDatastoreWithMostFree.Name -StorageFormat $StorageFormat}
	else {write-host "No hay espacio suficiente libre de 300 GB en el datastore '$($oDatastoreWithMostFree.Name)' para generar el nuevo disco"}

