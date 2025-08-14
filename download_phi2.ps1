Write-Host "Descargando modelo Phi-2 (más pequeño y accesible)..." -ForegroundColor Green

# Modelo Phi-2 (más pequeño, ~1.5GB)
$url = "https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf"
$output = "models/phi-2.Q4_K_M.gguf"

if (!(Test-Path "models")) {
    New-Item -ItemType Directory -Path "models" -Force
    Write-Host "Carpeta models creada" -ForegroundColor Yellow
}

if (Test-Path $output) {
    Write-Host "Modelo ya existe!" -ForegroundColor Yellow
} else {
    Write-Host "Descargando Phi-2 (1.5GB)..." -ForegroundColor Cyan
    Write-Host "Esto puede tomar varios minutos..." -ForegroundColor Yellow
    
    try {
        # Usar TLS 1.2 para compatibilidad
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # Descargar con progreso
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $output)
        
        Write-Host "Descarga completada!" -ForegroundColor Green
        Write-Host "Modelo guardado en: $output" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Error al descargar: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Intenta descargar manualmente desde: $url" -ForegroundColor Yellow
    }
}




