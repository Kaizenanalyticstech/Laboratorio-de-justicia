Write-Host "Descargando modelo TinyLlama..." -ForegroundColor Green

$url = "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat.Q4_K_M.gguf"
$output = "models/tinyllama-1.1b-chat.Q4_K_M.gguf"

if (!(Test-Path "models")) {
    New-Item -ItemType Directory -Path "models" -Force
}

if (Test-Path $output) {
    Write-Host "Modelo ya existe!" -ForegroundColor Yellow
} else {
    Write-Host "Descargando..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $output
    Write-Host "Descarga completada!" -ForegroundColor Green
}




