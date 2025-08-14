# Script para instalar Docker Desktop en Windows

Write-Host "Instalando Docker Desktop para Windows..." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan

# Verificar si Docker ya está instalado
Write-Host "Verificando si Docker ya esta instalado..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "Docker ya esta instalado: $dockerVersion" -ForegroundColor Green
    Write-Host "Puedes ejecutar setup_simple.ps1 ahora" -ForegroundColor Cyan
    exit 0
} catch {
    Write-Host "Docker no esta instalado, procediendo con la instalacion..." -ForegroundColor Yellow
}

# Verificar si WSL2 está habilitado
Write-Host "Verificando WSL2..." -ForegroundColor Yellow
try {
    $wslVersion = wsl --version
    Write-Host "WSL2 encontrado: $wslVersion" -ForegroundColor Green
} catch {
    Write-Host "WSL2 no esta instalado o habilitado" -ForegroundColor Yellow
    Write-Host "Habilitando WSL2..." -ForegroundColor Cyan
    
    try {
        # Habilitar WSL
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        
        Write-Host "WSL habilitado. Reinicia tu computadora y ejecuta este script nuevamente" -ForegroundColor Green
        Write-Host "O descarga WSL2 manualmente desde: https://docs.microsoft.com/en-us/windows/wsl/install" -ForegroundColor Yellow
        exit 1
    } catch {
        Write-Host "Error al habilitar WSL. Ejecuta como administrador" -ForegroundColor Red
        exit 1
    }
}

# Descargar Docker Desktop
Write-Host "Descargando Docker Desktop..." -ForegroundColor Yellow
$dockerUrl = "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
$dockerInstaller = "DockerDesktopInstaller.exe"

try {
    Write-Host "Descargando Docker Desktop (puede tomar varios minutos)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $dockerUrl -OutFile $dockerInstaller -UseBasicParsing
    
    Write-Host "Docker Desktop descargado exitosamente!" -ForegroundColor Green
    Write-Host "Instalando Docker Desktop..." -ForegroundColor Yellow
    
    # Instalar Docker Desktop
    Start-Process -FilePath $dockerInstaller -ArgumentList "install --quiet" -Wait
    
    Write-Host "Docker Desktop instalado!" -ForegroundColor Green
    Write-Host "Reinicia tu computadora para completar la instalacion" -ForegroundColor Yellow
    Write-Host "Despues de reiniciar, ejecuta setup_simple.ps1" -ForegroundColor Cyan
    
    # Limpiar archivo de instalación
    Remove-Item $dockerInstaller -Force
    
} catch {
    Write-Host "Error al descargar o instalar Docker Desktop: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Descarga manualmente desde: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    Write-Host "Instala y reinicia tu computadora" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Pasos manuales si la instalacion automatica falla:" -ForegroundColor Yellow
Write-Host "1. Ve a https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
Write-Host "2. Descarga Docker Desktop para Windows" -ForegroundColor Cyan
Write-Host "3. Instala y reinicia tu computadora" -ForegroundColor Cyan
Write-Host "4. Abre Docker Desktop y espera a que inicie" -ForegroundColor Cyan
Write-Host "5. Ejecuta setup_simple.ps1" -ForegroundColor Cyan




