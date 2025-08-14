# 🔍 Script para verificar el estado del ODR Chatbot MVP

Write-Host "🔍 Verificando estado del ODR Chatbot MVP..." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan

# Verificar Docker
Write-Host "📋 Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker no está disponible" -ForegroundColor Red
    exit 1
}

# Verificar contenedores
Write-Host "📋 Verificando contenedores..." -ForegroundColor Yellow
try {
    $containers = docker compose ps
    Write-Host "📊 Estado de contenedores:" -ForegroundColor Cyan
    Write-Host $containers -ForegroundColor Gray
} catch {
    Write-Host "❌ Error al verificar contenedores" -ForegroundColor Red
}

# Verificar puertos
Write-Host "📋 Verificando puertos..." -ForegroundColor Yellow

$ports = @(
    @{Port = 3000; Service = "Web UI"},
    @{Port = 5000; Service = "API"},
    @{Port = 5432; Service = "PostgreSQL"},
    @{Port = 8080; Service = "TEI"},
    @{Port = 8081; Service = "LLaMA"}
)

foreach ($port in $ports) {
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $port.Port -InformationLevel Quiet
        if ($connection) {
            Write-Host "✅ Puerto $($port.Port) ($($port.Service)): Abierto" -ForegroundColor Green
        } else {
            Write-Host "❌ Puerto $($port.Port) ($($port.Service)): Cerrado" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Puerto $($port.Port) ($($port.Service)): Error al verificar" -ForegroundColor Red
    }
}

# Verificar servicios web
Write-Host "📋 Verificando servicios web..." -ForegroundColor Yellow

# API Health
try {
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 5
    if ($apiResponse.StatusCode -eq 200) {
        Write-Host "✅ API Health: Funcionando" -ForegroundColor Green
        Write-Host "   Respuesta: $($apiResponse.Content)" -ForegroundColor Gray
    } else {
        Write-Host "⚠️  API Health: Código $($apiResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ API Health: No responde" -ForegroundColor Red
}

# Web UI
try {
    $webResponse = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
    if ($webResponse.StatusCode -eq 200) {
        Write-Host "✅ Web UI: Funcionando" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Web UI: Código $($webResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Web UI: No responde" -ForegroundColor Red
}

# Verificar modelo
Write-Host "📋 Verificando modelo..." -ForegroundColor Yellow
$modelPath = "models/phi-2.Q4_K_M.gguf"
if (Test-Path $modelPath) {
    $modelSize = (Get-Item $modelPath).Length / 1GB
    Write-Host "✅ Modelo encontrado: $modelPath" -ForegroundColor Green
    Write-Host "   Tamaño: $([math]::Round($modelSize, 2)) GB" -ForegroundColor Gray
} else {
    Write-Host "⚠️  Modelo no encontrado: $modelPath" -ForegroundColor Yellow
    Write-Host "   El sistema funcionará sin LLM" -ForegroundColor Cyan
}

# Verificar archivos de configuración
Write-Host "📋 Verificando configuración..." -ForegroundColor Yellow
$configFiles = @(".env", "docker-compose.yml", "services/api/main.py", "web/index.html")
foreach ($file in $configFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file: Existe" -ForegroundColor Green
    } else {
        Write-Host "❌ $file: No existe" -ForegroundColor Red
    }
}

# Mostrar logs recientes
Write-Host "📋 Logs recientes (últimas 10 líneas)..." -ForegroundColor Yellow
try {
    $logs = docker compose logs --tail=10
    Write-Host "📄 Logs recientes:" -ForegroundColor Cyan
    Write-Host $logs -ForegroundColor Gray
} catch {
    Write-Host "⚠️  No se pudieron obtener logs" -ForegroundColor Yellow
}

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "🎯 Resumen de verificación completado" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "🌐 URLs de acceso:" -ForegroundColor Yellow
Write-Host "   Web UI: http://localhost:3000" -ForegroundColor Cyan
Write-Host "   API Health: http://localhost:5000/health" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔧 Comandos útiles:" -ForegroundColor Yellow
Write-Host "   Ver logs completos: docker compose logs -f" -ForegroundColor Gray
Write-Host "   Reiniciar servicios: docker compose restart" -ForegroundColor Gray
Write-Host "   Detener todo: docker compose down" -ForegroundColor Gray
Write-Host "   Verificar estado: .\verificar_estado.ps1" -ForegroundColor Gray




