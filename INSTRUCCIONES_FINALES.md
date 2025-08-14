# 🚀 Instrucciones Finales - ODR Chatbot MVP

## ✅ Configuración Completada

Tu proyecto `odr-chatbot-mvp` ha sido configurado correctamente con los siguientes puertos:

- **API FastAPI**: http://localhost:5000
- **Web UI**: http://localhost:3000
- **PostgreSQL**: puerto 5432
- **TEI (embeddings)**: puerto 8080
- **llama.cpp (LLM)**: puerto 8081

## 🎯 Pasos para Ejecutar

### 1. Descargar modelos (una sola vez)
```bash
bash scripts/setup_models.sh
```

### 2. Configurar variables de entorno
```bash
cp env.example .env
```

### 3. Levantar servicios
```bash
docker compose up --build
```

### 4. Verificar funcionamiento
```bash
# Probar API
curl http://localhost:5000/health
# Debe devolver: {"ok": true}

# Abrir en navegador
# http://localhost:3000
```

## 🔧 Archivos Modificados

- ✅ `docker-compose.yml` - Puertos fijos y valores por defecto
- ✅ `services/api/Dockerfile` - Puerto 5000
- ✅ `web/app.js` - API base en puerto 5000
- ✅ `env.example` - Configuración de puertos
- ✅ `README.md` - Instrucciones actualizadas
- ✅ `scripts/test_setup.sh` - Script de verificación

## 🎉 Resultado Final

Después de ejecutar los comandos:

1. **Abre http://localhost:3000** en tu navegador
2. **Sube un PDF** usando la interfaz web
3. **Haz preguntas** sobre el documento
4. **El bot responderá** con citas [Documento p.X]

## 🐛 Solución de Problemas

### Si la API no responde:
```bash
docker compose logs api
```

### Si la web no carga:
```bash
docker compose logs web
```

### Si los modelos no se descargan:
```bash
# Verificar conexión a internet
curl -I https://huggingface.co
```

## 📝 Notas Importantes

- **Sin cuotas**: Todo corre local, sin servicios de pago
- **Modelo liviano**: TinyLlama-1.1B para CPU
- **Datos persistentes**: Los PDFs y embeddings se guardan en volúmenes Docker
- **CORS configurado**: La web puede comunicarse con la API

¡Tu chatbot RAG está listo para usar! 🎊

