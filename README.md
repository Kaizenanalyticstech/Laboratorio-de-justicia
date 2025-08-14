<<<<<<< HEAD
# 🤖 ODR Chatbot - Asistente Legal Inteligente

Un chatbot inteligente para procesamiento de documentos legales usando IA, con capacidad de subir PDFs y hacer preguntas sobre su contenido.

## ✨ Características

- 📄 **Subida de PDFs** - Procesa documentos legales automáticamente
- 🤖 **Chat con IA** - Haz preguntas sobre el contenido de los documentos
- 🔍 **Búsqueda Semántica** - Encuentra información relevante en los documentos
- 💾 **Base de Datos Vectorial** - Almacenamiento eficiente con PostgreSQL + pgvector
- 🌐 **Interfaz Web Moderna** - Diseño profesional y responsive
- 🐳 **Docker Ready** - Fácil despliegue con contenedores
- ☁️ **Cloud Ready** - Listo para desplegar en Render, Railway, VPS, etc.

## 🚀 Despliegue Rápido

### Opción 1: Local con Docker
```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/odr-chatbot.git
cd odr-chatbot

# Levantar servicios
docker compose -f docker-compose-working.yml up --build -d

# Acceder a la aplicación
# Frontend: http://localhost:3000
# API: http://localhost:5000/health
```

### Opción 2: Render (Recomendado - Gratis)
1. Ve a [render.com](https://render.com)
2. Conecta tu repositorio de GitHub
3. Render detectará automáticamente el `render.yaml`
4. ¡Listo! Tu chatbot estará online

## 🛠️ Tecnologías

### Backend
- **FastAPI** - API moderna y rápida
- **PostgreSQL** - Base de datos principal
- **pgvector** - Búsqueda vectorial
- **PyPDF** - Procesamiento de PDFs
- **Uvicorn** - Servidor ASGI

### Frontend
- **HTML5/CSS3** - Interfaz moderna
- **JavaScript ES6+** - Funcionalidad dinámica
- **Font Awesome** - Iconos profesionales
- **Google Fonts** - Tipografía elegante

### Infraestructura
- **Docker** - Contenedores
- **Docker Compose** - Orquestación
- **Nginx** - Servidor web
- **PostgreSQL** - Base de datos

## 📁 Estructura del Proyecto

```
odr-chatbot/
├── services/
│   └── api/
│       ├── main.py          # API principal
│       ├── requirements.txt # Dependencias Python
│       └── Dockerfile       # Contenedor API
├── web/
│   ├── index.html          # Interfaz principal
│   ├── style.css           # Estilos CSS
│   ├── app.js              # JavaScript
│   ├── nginx.conf          # Configuración Nginx
│   └── Dockerfile          # Contenedor Web
├── docker-compose.yml      # Configuración Docker
├── render.yaml             # Configuración Render
├── railway.json            # Configuración Railway
├── deploy.sh               # Script VPS
└── README.md               # Este archivo
```

## 🔧 Configuración

### Variables de Entorno
```bash
DATABASE_URL=postgresql://usuario:password@host:puerto/database
FILES_DIR=/tmp/uploads
CORS_ORIGINS=*
```

### Puertos
- **3000** - Frontend (Nginx)
- **5000** - API (FastAPI)
- **5432** - Base de datos (PostgreSQL)

## 📖 Uso

### 1. Subir Documento
1. Ve a la interfaz web
2. Haz clic en "Seleccionar archivo PDF"
3. Elige tu documento legal
4. Haz clic en "Subir e Indexar Documento"

### 2. Hacer Preguntas
1. Una vez subido el documento
2. Escribe tu pregunta en el chat
3. El sistema buscará información relevante
4. Recibirás una respuesta basada en el documento

## 🧪 Pruebas

### API Health Check
```bash
curl http://localhost:5000/health
# Respuesta: {"ok": true}
```

### Subir Archivo
```bash
curl -X POST http://localhost:5000/ingest \
  -F "file=@documento.pdf"
```

### Chat
```bash
curl -X POST http://localhost:5000/chat \
  -H "Content-Type: application/json" \
  -d '{"query": "¿Qué dice sobre los derechos?"}'
```

## 🚀 Despliegue

### Render (Gratis)
- [Guía completa](DEPLOYMENT.md#render-recomendado---gratis)
- Despliegue automático desde GitHub
- Base de datos PostgreSQL incluida

### Railway (Gratis)
- [Guía completa](DEPLOYMENT.md#railway-alternativa---gratis)
- Detección automática de configuración
- Escalado automático

### VPS (Control Total)
- [Guía completa](DEPLOYMENT.md#vps-control-total)
- Script de despliegue automático
- Configuración Nginx incluida

## 🔒 Seguridad

- ✅ Validación de tipos de archivo
- ✅ Límites de tamaño de archivo
- ✅ Variables de entorno seguras
- ✅ CORS configurado
- ✅ Sanitización de entrada

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🆘 Soporte

- 📧 Email: tu-email@ejemplo.com
- 🐛 Issues: [GitHub Issues](https://github.com/tu-usuario/odr-chatbot/issues)
- 📖 Documentación: [Wiki](https://github.com/tu-usuario/odr-chatbot/wiki)

## 🙏 Agradecimientos

- [FastAPI](https://fastapi.tiangolo.com/) - Framework web moderno
- [PostgreSQL](https://www.postgresql.org/) - Base de datos robusta
- [pgvector](https://github.com/pgvector/pgvector) - Búsqueda vectorial
- [Docker](https://www.docker.com/) - Contenedores
- [Render](https://render.com/) - Plataforma de despliegue

---

⭐ **¡Dale una estrella al proyecto si te gustó!**

🔄 **Última actualización:** Agosto 2025
=======
# Laboratorio-de-justicia
>>>>>>> 47d8c42462a317013572907df56d6667768db96b
