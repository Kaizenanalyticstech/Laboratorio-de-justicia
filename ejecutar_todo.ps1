# Script maestro para ejecutar todo automáticamente

Write-Host "🚀 Script Maestro - ODR Chatbot MVP" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan

# Verificar si Docker está instalado
Write-Host "Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker encontrado: $dockerVersion" -ForegroundColor Green
    Write-Host "Procediendo con la configuracion..." -ForegroundColor Cyan
    
    # Ejecutar configuración automática
    Write-Host "Ejecutando configuracion automatica..." -ForegroundColor Yellow
    & ".\setup_simple.ps1"
    
} catch {
    Write-Host "❌ Docker no esta instalado" -ForegroundColor Red
    Write-Host "¿Quieres instalar Docker Desktop automaticamente?" -ForegroundColor Yellow
    Write-Host "1. Si - Instalar Docker automaticamente" -ForegroundColor Cyan
    Write-Host "2. No - Instalar manualmente" -ForegroundColor Cyan
    
    $response = Read-Host "Selecciona una opcion (1 o 2)"
    
    if ($response -eq "1") {
        Write-Host "Instalando Docker Desktop..." -ForegroundColor Yellow
        & ".\instalar_docker.ps1"
    } else {
        Write-Host ""
        Write-Host "📋 Pasos manuales para instalar Docker:" -ForegroundColor Yellow
        Write-Host "1. Ve a https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
        Write-Host "2. Descarga Docker Desktop para Windows" -ForegroundColor Cyan
        Write-Host "3. Instala y reinicia tu computadora" -ForegroundColor Cyan
        Write-Host "4. Abre Docker Desktop y espera a que inicie" -ForegroundColor Cyan
        Write-Host "5. Ejecuta este script nuevamente: .\ejecutar_todo.ps1" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "🎯 Proceso completado!" -ForegroundColor Green
Write-Host "Si todo salio bien, tu chatbot estara disponible en:" -ForegroundColor Cyan
Write-Host "   Web UI: http://localhost:3000" -ForegroundColor Yellow
Write-Host "   API: http://localhost:5000/health" -ForegroundColor Yellow




