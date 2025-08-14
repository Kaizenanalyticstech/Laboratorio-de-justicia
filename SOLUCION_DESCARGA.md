# 🔧 Soluciones para Problema de Descarga - ODR Chatbot MVP

## 🚨 Problema Identificado
No se puede descargar el modelo desde HuggingFace. Aquí tienes **3 soluciones**:

## 🎯 **Solución 1: Modelo Alternativo (Recomendado)**

### Descargar Phi-2 (más pequeño, ~1.5GB)
```powershell
# Ejecutar el script mejorado
powershell -ExecutionPolicy Bypass -File download_phi2.ps1
```

### Descarga Manual de Phi-2
1. Ve a: https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf
2. Descarga el archivo (1.5GB)
3. Colócalo en `models/phi-2.Q4_K_M.gguf`

## 🎯 **Solución 2: Usar Sin LLM (Funcionalidad Básica)**

### Configuración sin modelo de LLM
```powershell
# Usar la versión simplificada
Copy-Item docker-compose-simple.yml docker-compose.yml
docker compose up --build
```

**Funcionalidad disponible:**
- ✅ Subir PDFs
- ✅ Extraer texto y crear embeddings
- ✅ Búsqueda semántica
- ❌ Chat con LLM (necesita modelo)

## 🎯 **Solución 3: Modelos Más Pequeños**

### Opción A: TinyLlama (600MB)
```powershell
# Descargar versión más pequeña
$url = "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat.Q2_K.gguf"
$output = "models/tinyllama-1.1b-chat.Q2_K.gguf"
Invoke-WebRequest -Uri $url -OutFile $output
```

### Opción B: Phi-1.5 (800MB)
```powershell
$url = "https://huggingface.co/TheBloke/phi-1_5-GGUF/resolve/main/phi-1_5.Q4_K_M.gguf"
$output = "models/phi-1_5.Q4_K_M.gguf"
Invoke-WebRequest -Uri $url -OutFile $output
```

## 🔧 **Solución 4: Usar VPN o Proxy**

Si el problema es de conectividad:

### Con VPN
1. Conecta una VPN
2. Ejecuta el script de descarga
3. Desconecta la VPN

### Con Proxy
```powershell
# Configurar proxy si es necesario
$proxy = "http://tu-proxy:puerto"
$webClient = New-Object System.Net.WebClient
$webClient.Proxy = New-Object System.Net.WebProxy($proxy)
```

## 🚀 **Comandos de Prueba**

### Verificar conectividad
```powershell
# Probar acceso a HuggingFace
Invoke-WebRequest -Uri "https://huggingface.co" -UseBasicParsing

# Probar descarga pequeña
Invoke-WebRequest -Uri "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat.Q2_K.gguf" -OutFile "test.gguf"
```

### Ejecutar sin modelo
```powershell
# Copiar configuración simple
Copy-Item docker-compose-simple.yml docker-compose.yml

# Levantar servicios básicos
docker compose up --build
```

## 📋 **Estado de Funcionalidad**

| Componente | Con Modelo | Sin Modelo |
|------------|------------|------------|
| Subir PDF | ✅ | ✅ |
| Extraer texto | ✅ | ✅ |
| Embeddings | ✅ | ✅ |
| Búsqueda | ✅ | ✅ |
| Chat LLM | ✅ | ❌ |

## 🎯 **Recomendación**

1. **Intenta Solución 1** (Phi-2) - Modelo más pequeño
2. **Si falla, usa Solución 2** (sin LLM) - Para probar funcionalidad básica
3. **Luego agrega el modelo** cuando tengas mejor conectividad

¡Cualquier solución te permitirá probar el sistema! 🎉




