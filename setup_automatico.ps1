# 🚀 Script Automático para ODR Chatbot MVP
# Ejecuta todo el proceso de configuración automáticamente

Write-Host "🚀 Iniciando configuración automática del ODR Chatbot MVP..." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

# Paso 1: Verificar Docker
Write-Host "📋 Paso 1: Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker no está instalado o no está corriendo" -ForegroundColor Red
    Write-Host "💡 Instala Docker Desktop desde: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    Write-Host "🔧 Después de instalar, reinicia PowerShell y ejecuta este script nuevamente" -ForegroundColor Yellow
    exit 1
}

# Paso 2: Crear carpeta models si no existe
Write-Host "📋 Paso 2: Preparando estructura de carpetas..." -ForegroundColor Yellow
if (!(Test-Path "models")) {
    New-Item -ItemType Directory -Path "models" -Force
    Write-Host "✅ Carpeta models creada" -ForegroundColor Green
} else {
    Write-Host "✅ Carpeta models ya existe" -ForegroundColor Green
}

# Paso 3: Copiar archivo .env si no existe
Write-Host "📋 Paso 3: Configurando variables de entorno..." -ForegroundColor Yellow
if (!(Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "✅ Archivo .env creado desde .env.example" -ForegroundColor Green
    } else {
        Write-Host "⚠️  No se encontró .env.example, creando .env básico..." -ForegroundColor Yellow
        @"
POSTGRES_USER=odr_user
POSTGRES_PASSWORD=odr_pass
POSTGRES_DB=odr_db
TEI_MODEL_ID=BAAI/bge-m3
LLAMA_MODEL_PATH=/models/phi-2.Q4_K_M.gguf
LLAMA_CTX_SIZE=4096
LLAMA_PARALLEL=2
"@ | Out-File -FilePath ".env" -Encoding UTF8
        Write-Host "✅ Archivo .env básico creado" -ForegroundColor Green
    }
} else {
    Write-Host "✅ Archivo .env ya existe" -ForegroundColor Green
}

# Paso 4: Intentar descargar modelo (opcional)
Write-Host "📋 Paso 4: Intentando descargar modelo Phi-2..." -ForegroundColor Yellow
$modelPath = "models/phi-2.Q4_K_M.gguf"
if (Test-Path $modelPath) {
    Write-Host "✅ Modelo ya existe: $modelPath" -ForegroundColor Green
} else {
    Write-Host "⏳ Intentando descargar modelo Phi-2 (1.5GB)..." -ForegroundColor Cyan
    Write-Host "💡 Si la descarga falla, el sistema funcionará sin LLM" -ForegroundColor Yellow
    
    try {
        # Usar TLS 1.2 para compatibilidad
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $url = "https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf"
        $webClient = New-Object System.Net.WebClient
        
        # Mostrar progreso
        Write-Host "📥 Descargando... (esto puede tomar varios minutos)" -ForegroundColor Cyan
        $webClient.DownloadFile($url, $modelPath)
        
        Write-Host "✅ Modelo descargado exitosamente!" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  No se pudo descargar el modelo: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "💡 El sistema funcionará sin LLM (solo embeddings y búsqueda)" -ForegroundColor Cyan
        
        # Usar configuración sin LLM
        if (Test-Path "docker-compose-simple.yml") {
            Copy-Item "docker-compose-simple.yml" "docker-compose.yml"
            Write-Host "✅ Configurado para funcionar sin LLM" -ForegroundColor Green
        }
    }
}

# Paso 5: Detener contenedores existentes
Write-Host "📋 Paso 5: Limpiando contenedores existentes..." -ForegroundColor Yellow
try {
    docker compose down -v
    Write-Host "✅ Contenedores detenidos" -ForegroundColor Green
} catch {
    Write-Host "⚠️  No había contenedores corriendo" -ForegroundColor Yellow
}

# Paso 6: Construir y levantar servicios
Write-Host "📋 Paso 6: Construyendo y levantando servicios..." -ForegroundColor Yellow
Write-Host "🔨 Esto puede tomar varios minutos..." -ForegroundColor Cyan

try {
    docker compose up --build -d
    Write-Host "✅ Servicios iniciados correctamente!" -ForegroundColor Green
} catch {
    Write-Host "❌ Error al levantar servicios: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "🔧 Revisa los logs con: docker compose logs" -ForegroundColor Yellow
    exit 1
}

# Paso 7: Esperar a que los servicios estén listos
Write-Host "📋 Paso 7: Esperando a que los servicios estén listos..." -ForegroundColor Yellow
Write-Host "⏳ Esperando 30 segundos para que todo se inicialice..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

# Paso 8: Verificar servicios
Write-Host "📋 Paso 8: Verificando servicios..." -ForegroundColor Yellow

# Verificar API
try {
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 10
    if ($apiResponse.StatusCode -eq 200) {
        Write-Host "✅ API funcionando: http://localhost:5000/health" -ForegroundColor Green
    } else {
        Write-Host "⚠️  API respondió con código: $($apiResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  API no responde aún (puede estar iniciando): $($_.Exception.Message)" -ForegroundColor Yellow
}

# Verificar Web
try {
    $webResponse = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 10
    if ($webResponse.StatusCode -eq 200) {
        Write-Host "✅ Web UI funcionando: http://localhost:3000" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Web UI respondió con código: $($webResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Web UI no responde aún (puede estar iniciando): $($_.Exception.Message)" -ForegroundColor Yellow
}

# Paso 9: Mostrar estado final
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🎉 ¡Configuración automática completada!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "📊 Estado de servicios:" -ForegroundColor Yellow
docker compose ps

Write-Host ""
Write-Host "🌐 URLs de acceso:" -ForegroundColor Yellow
Write-Host "   Web UI: http://localhost:3000" -ForegroundColor Cyan
Write-Host "   API Health: http://localhost:5000/health" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔧 Comandos útiles:" -ForegroundColor Yellow
Write-Host "   Ver logs: docker compose logs -f" -ForegroundColor Gray
Write-Host "   Detener: docker compose down" -ForegroundColor Gray
Write-Host "   Reiniciar: docker compose restart" -ForegroundColor Gray

Write-Host ""
Write-Host "📝 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Abre http://localhost:3000 en tu navegador" -ForegroundColor Cyan
Write-Host "   2. Sube un PDF para probar" -ForegroundColor Cyan
Write-Host "   3. Haz una pregunta al chatbot" -ForegroundColor Cyan

Write-Host ""
Write-Host "🎯 ¡Tu chatbot RAG está listo para usar!" -ForegroundColor Green




