# Script para descargar modelos en Windows PowerShell

Write-Host "📥 Descargando TinyLlama 1.1B Chat (GGUF Q4_K_M)..." -ForegroundColor Green

$modelUrl = "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat.Q4_K_M.gguf"
$modelPath = "models/tinyllama-1.1b-chat.Q4_K_M.gguf"

if (Test-Path $modelPath) {
    Write-Host "✅ Modelo ya existe: $modelPath" -ForegroundColor Yellow
} else {
    Write-Host "⏳ Descargando modelo (esto puede tomar varios minutos)..." -ForegroundColor Cyan
    
    try {
        # Crear directorio si no existe
        if (!(Test-Path "models")) {
            New-Item -ItemType Directory -Path "models" -Force
        }
        
        # Descargar el modelo
        Invoke-WebRequest -Uri $modelUrl -OutFile $modelPath -UseBasicParsing
        
        Write-Host "✅ Modelo descargado exitosamente!" -ForegroundColor Green
        Write-Host "📁 Ubicación: $modelPath" -ForegroundColor Cyan
    }
    catch {
        Write-Host "❌ Error al descargar el modelo: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "💡 Intenta descargar manualmente desde: $modelUrl" -ForegroundColor Yellow
    }
}

Write-Host "🎉 Proceso completado!" -ForegroundColor Green




