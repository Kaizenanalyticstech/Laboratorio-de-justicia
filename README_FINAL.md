# 🚀 ODR Chatbot MVP - Ejecución Automática

## 🎯 **Ejecutar Todo Automáticamente**

### **Opción 1: Script Maestro (Recomendado)**
```powershell
# Ejecuta todo automáticamente
powershell -ExecutionPolicy Bypass -File ejecutar_todo.ps1
```

Este script:
- ✅ Verifica si Docker está instalado
- ✅ Instala Docker Desktop si es necesario
- ✅ Configura todo el proyecto automáticamente
- ✅ Descarga el modelo (o usa versión sin LLM)
- ✅ Levanta todos los servicios
- ✅ Verifica que todo funcione

### **Opción 2: Scripts Individuales**

#### **Si Docker NO está instalado:**
```powershell
# Instalar Docker Desktop
powershell -ExecutionPolicy Bypass -File instalar_docker.ps1
```

#### **Si Docker YA está instalado:**
```powershell
# Configurar y ejecutar el proyecto
powershell -ExecutionPolicy Bypass -File setup_simple.ps1
```

#### **Para verificar el estado:**
```powershell
# Verificar que todo funcione
powershell -ExecutionPolicy Bypass -File verificar_estado.ps1
```

## 📋 **Scripts Disponibles**

| Script | Función |
|--------|---------|
| `ejecutar_todo.ps1` | **Script maestro** - Hace todo automáticamente |
| `instalar_docker.ps1` | Instala Docker Desktop |
| `setup_simple.ps1` | Configura y ejecuta el proyecto |
| `verificar_estado.ps1` | Verifica el estado de todos los servicios |
| `download_phi2.ps1` | Descarga el modelo Phi-2 |
| `SOLUCION_DESCARGA.md` | Soluciones si hay problemas de descarga |

## 🎯 **Proceso Automático Completo**

### **Paso 1: Ejecutar Script Maestro**
```powershell
powershell -ExecutionPolicy Bypass -File ejecutar_todo.ps1
```

### **Paso 2: Esperar a que Complete**
El script hará todo automáticamente:
- 🔍 Verificar Docker
- 📥 Instalar Docker (si es necesario)
- 📁 Crear carpetas
- ⚙️ Configurar variables
- 📦 Descargar modelo (opcional)
- 🐳 Levantar servicios
- ✅ Verificar funcionamiento

### **Paso 3: Usar el Chatbot**
- 🌐 Abrir: http://localhost:3000
- 📄 Subir un PDF
- 💬 Hacer preguntas

## 🔧 **Comandos Útiles**

### **Ver Estado de Servicios**
```powershell
docker compose ps
```

### **Ver Logs**
```powershell
docker compose logs -f
```

### **Detener Servicios**
```powershell
docker compose down
```

### **Reiniciar Servicios**
```powershell
docker compose restart
```

### **Verificar Puertos**
```powershell
netstat -ano | findstr :3000
netstat -ano | findstr :5000
```

## 🌐 **URLs de Acceso**

| Servicio | URL | Función |
|----------|-----|---------|
| **Web UI** | http://localhost:3000 | Interfaz del chatbot |
| **API Health** | http://localhost:5000/health | Verificar API |
| **PostgreSQL** | localhost:5432 | Base de datos |
| **TEI** | localhost:8080 | Embeddings |
| **LLaMA** | localhost:8081 | Modelo LLM |

## 📊 **Funcionalidades Disponibles**

### **Con Modelo LLM:**
- ✅ Subir PDFs
- ✅ Extraer texto
- ✅ Crear embeddings
- ✅ Búsqueda semántica
- ✅ Chat con LLM

### **Sin Modelo LLM:**
- ✅ Subir PDFs
- ✅ Extraer texto
- ✅ Crear embeddings
- ✅ Búsqueda semántica
- ❌ Chat con LLM

## 🚨 **Solución de Problemas**

### **Si Docker no se instala:**
1. Descarga manualmente: https://www.docker.com/products/docker-desktop/
2. Instala y reinicia
3. Ejecuta `setup_simple.ps1`

### **Si el modelo no se descarga:**
1. El sistema funcionará sin LLM
2. Usa `SOLUCION_DESCARGA.md` para alternativas
3. Descarga manualmente desde HuggingFace

### **Si los puertos están ocupados:**
```powershell
# Ver qué usa los puertos
netstat -ano | findstr :3000
netstat -ano | findstr :5000

# Detener procesos si es necesario
taskkill /PID [PID] /F
```

### **Si hay errores en los logs:**
```powershell
# Ver logs detallados
docker compose logs -f api
docker compose logs -f web
docker compose logs -f tei
docker compose logs -f llama
```

## 🎉 **¡Listo!**

Una vez que ejecutes `ejecutar_todo.ps1`, tu chatbot RAG estará completamente funcional en:

**🌐 http://localhost:3000**

¡Todo 100% autoalojado y sin cuotas mensuales! 🚀




