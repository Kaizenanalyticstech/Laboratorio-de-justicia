# 🚀 Instrucciones para Windows - ODR Chatbot MVP

## ✅ Configuración Completada

Tu proyecto está configurado correctamente. Solo necesitas completar estos pasos:

## 📥 Paso 1: Descargar el Modelo

### Opción A: Descarga Manual (Recomendado)
1. Ve a: https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat.Q4_K_M.gguf
2. Descarga el archivo
3. Colócalo en la carpeta `models/` de tu proyecto

### Opción B: Usar PowerShell
```powershell
# Crear carpeta models si no existe
mkdir models

# Descargar con PowerShell
$url = "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat.Q4_K_M.gguf"
$output = "models/tinyllama-1.1b-chat.Q4_K_M.gguf"
Invoke-WebRequest -Uri $url -OutFile $output
```

## 🐳 Paso 2: Instalar Docker Desktop

1. Descarga Docker Desktop para Windows: https://www.docker.com/products/docker-desktop/
2. Instala y reinicia tu computadora
3. Abre Docker Desktop y espera a que esté corriendo

## 🚀 Paso 3: Ejecutar el Proyecto

```powershell
# Verificar que Docker está corriendo
docker --version

# Levantar servicios
docker compose down -v
docker compose up --build
```

## ✅ Paso 4: Verificar Funcionamiento

### Verificar API:
```powershell
curl http://localhost:5000/health
# Debe devolver: {"ok": true}
```

### Verificar Web:
- Abre http://localhost:3000 en tu navegador
- Debe cargar la interfaz del chatbot

## 🔧 Solución de Problemas

### Si Docker no está disponible:
```powershell
# Verificar si Docker está instalado
docker --version

# Si no está instalado, instala Docker Desktop
```

### Si los puertos están ocupados:
```powershell
# Verificar qué está usando los puertos
netstat -ano | findstr :5000
netstat -ano | findstr :3000
```

### Si hay errores en los logs:
```powershell
# Ver logs de los servicios
docker compose logs -f api
docker compose logs -f web
docker compose logs -f tei
docker compose logs -f llama
```

## 📁 Estructura Final

```
odr-chatbot-mvp/
├── models/
│   └── tinyllama-1.1b-chat.Q4_K_M.gguf  ← Debes descargar este archivo
├── docker-compose.yml
├── .env
├── services/
├── web/
└── ...
```

## 🎯 Criterio de Éxito

- ✅ `http://localhost:3000` carga la UI
- ✅ `curl http://localhost:5000/health` devuelve `{"ok": true}`
- ✅ Puedes subir un PDF y hacer preguntas

¡Tu chatbot RAG estará listo para usar! 🎉




