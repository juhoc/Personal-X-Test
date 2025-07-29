# Ruta del archivo de log
$logFilePath = "WindowsUpdateConfig.log"

# Función para escribir en el log
function Write-Log {
    param(
        [string]$logMessage
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $logMessage"
    Add-Content -Path $logFilePath -Value $logEntry
}

# Función para verificar si una entrada de registro existe
function Test-RegistryEntry {
    param (
        [string]$path,
        [string]$name
    )

    $entry = Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
    return -not ($null -eq $entry)
}

# Validar si los valores ya existen en el registro
if (
    -not (Test-RegistryEntry -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -name "WUServer") -or
    -not (Test-RegistryEntry -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -name "WUStatusServer") -or
    -not (Test-RegistryEntry -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -name "NoAutoRebootWithLoggedOnUsers") -or
    -not (Test-RegistryEntry -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -name "DoNotAllowUpdateDeferralPolicies")
) {
    # 1. Agregar valores al registro
    Write-Log "Agregando valores al registro."
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $registryName1 = "WUServer"
    $registryName2 = "WUStatusServer"
    $registryValue = "http://WVPINSYSCENMX01.cb.bbvabancomer.com.mx:8530"
    New-ItemProperty -Path $registryPath -Name $registryName1 -Value $registryValue -Force
    New-ItemProperty -Path $registryPath -Name $registryName2 -Value $registryValue -Force

    # 2. Reiniciar el servicio de Windows Update
    Write-Log "Reiniciando el servicio de Windows Update."
    Restart-Service -Name wuauserv -Force

    # 3. Activar directivas de grupo
    Write-Log "Activando directivas de grupo."
    $gpoPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $gpoValues = @{
        "NoAutoRebootWithLoggedOnUsers" = 1
        "NoAutoUpdate" = 0
        "AUOptions" = 2
        "ScheduledInstallDay" = 0
        "ScheduledInstallTime" = 3
        "UseWUServer" = 1
        "RescheduleWaitTime" = 1
        "AllowMUUpdateService" = 1
    }

    $gpoValues.GetEnumerator() | ForEach-Object {
        $name = $_.Key
        $value = $_.Value
        New-ItemProperty -Path $gpoPath -Name $name -Value $value -Force
    }

    # 4. Configurar la ubicación del servicio de actualización de Microsoft
    Write-Log "Configurando la ubicación del servicio de actualización de Microsoft."
    $gpoPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $gpoValues2 = @{
        "WUServer" = "http://WVPINSYSCENMX01.cb.bbvabancomer.com.mx:8530"
        "WUStatusServer" = "http://WVPINSYSCENMX01.cb.bbvabancomer.com.mx:8530"
    }

    $gpoValues2.GetEnumerator() | ForEach-Object {
        $name = $_.Key
        $value = $_.Value
        New-ItemProperty -Path $gpoPath2 -Name $name -Value $value -Force
    }

    # 5. Habilitar políticas adicionales
    Write-Log "Habilitando políticas adicionales."
    $gpoPath3 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $gpoValues3 = @{
        "DoNotAllowUpdateDeferralPolicies" = 1
    }

    $gpoValues3.GetEnumerator() | ForEach-Object {
        $name = $_.Key
        $value = $_.Value
        New-ItemProperty -Path $gpoPath3 -Name $name -Value $value -Force
    }

    # 6. Ejecutar gpupdate
    Write-Log "Ejecutando gpupdate."
    gpupdate /force
}

# 7. Iniciar la descarga e instalación de parches
Write-Log "Iniciando la descarga e instalación de parches."

# Configurar el servicio de Actualizaciones Automáticas
$automaticUpdates = New-Object -ComObject Microsoft.Update.AutoUpdate
$automaticUpdates.DetectNow()

# Esperar a que se complete la detección de actualizaciones
Start-Sleep -Seconds 60

# Crear un objeto de búsqueda de actualizaciones
$updateSession = New-Object -ComObject Microsoft.Update.Session
$updateSearcher = $updateSession.CreateUpdateSearcher()

# Buscar actualizaciones pendientes
$searchResult = $updateSearcher.Search("IsInstalled=0")

# Intentar descargar e instalar actualizaciones con reintento
$maxRetries = 3
$currentRetry = 0
$retryInterval = 60  # segundos

while ($currentRetry -lt $maxRetries) {
    $currentRetry++

    try {
        # Descargar e instalar actualizaciones
        $updateDownloader = $updateSession.CreateUpdateDownloader()
        $updateDownloader.Updates = $searchResult.Updates
        $updateDownloader.Download()

        $updateInstaller = $updateSession.CreateUpdateInstaller()
        $updateInstaller.Updates = $searchResult.Updates
        $installationResult = $updateInstaller.Install()

        # Verificar el resultado de la instalación
        if ($installationResult.ResultCode -eq 2) {
            Write-Host "Instalación exitosa."

            # Registrar los parches instalados
            $installedPatches = $searchResult.Updates | ForEach-Object { $_.Title }
            Write-Log "Parches instalados: $($installedPatches -join ', ')"
        } else {
            Write-Host "La instalación falló. Código de resultado: $($installationResult.ResultCode)"
        }

        # Salir del bucle si la instalación fue exitosa
        break
    } catch {
        # Capturar la excepción y esperar antes de intentar nuevamente
        Write-Host "Error al intentar descargar o instalar actualizaciones: $_"
        Write-Host "Reintentando en $retryInterval segundos..."
        Start-Sleep -Seconds $retryInterval
    }
}

# Verificar si se necesita reiniciar
if ($automaticUpdates.Settings.RebootRequired) {
    Write-Host "Reinicio necesario. Reiniciando..."
    Restart-Computer -Force
}


# Detener los servicios
Stop-Service -Name bits, wuauserv, appidsvc, cryptsvc

# Eliminar archivos qmgr*.dat
Remove-Item -Path "$env:ALLUSERSPROFILE\Microsoft\Network\Downloader\qmgr*.dat" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:HOMEDRIVE\Users\All Users\Microsoft\Network\Downloader\qmgr*.dat" -Force -ErrorAction SilentlyContinue

# Eliminar archivos de SoftwareDistribution
Remove-Item -Path "$env:WINDIR\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue

# Iniciar los servicios
Start-Service -Name bits, wuauserv, appidsvc, cryptsvc


Write-Log "Configuración completada."
