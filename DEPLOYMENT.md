# 🚀 Guía de Despliegue - ODR Chatbot

## 🌐 Opciones de Despliegue Online

### **1. 🎯 Render (Recomendado - Gratis)**

**Pasos:**
1. Ve a [render.com](https://render.com) y crea una cuenta
2. Conecta tu repositorio de GitHub
3. Crea un nuevo **Web Service**
4. Selecciona tu repositorio
5. Configura:
   - **Name:** `odr-chatbot-api`
   - **Environment:** `Python`
   - **Build Command:** `pip install -r services/api/requirements.txt`
   - **Start Command:** `cd services/api && uvicorn main:app --host 0.0.0.0 --port $PORT`

6. Crea una **PostgreSQL Database**:
   - **Name:** `odr-chatbot-db`
   - Conecta la variable `DATABASE_URL` al servicio API

7. Crea un **Static Site** para el frontend:
   - **Name:** `odr-chatbot-web`
   - **Build Command:** `echo "Building static site"`
   - **Publish Directory:** `web`

**URLs resultantes:**
- Frontend: `https://tu-app.onrender.com`
- API: `https://tu-api.onrender.com`

---

### **2. ☁️ Railway (Alternativa - Gratis)**

**Pasos:**
1. Ve a [railway.app](https://railway.app)
2. Conecta tu repositorio
3. Railway detectará automáticamente el `railway.json`
4. Configura las variables de entorno:
   - `DATABASE_URL`
   - `FILES_DIR`
   - `CORS_ORIGINS`

---

### **3. 🐳 VPS (Control Total)**

**Pasos:**
1. Contrata un VPS (DigitalOcean, Linode, Vultr)
2. Conecta por SSH
3. Ejecuta el script de despliegue:

```bash
# Descargar el script
wget https://raw.githubusercontent.com/tu-usuario/odr-chatbot/main/deploy.sh
chmod +x deploy.sh
./deploy.sh
```

4. Configura tu dominio DNS
5. Actualiza la configuración de Nginx

---

### **4. 🔧 Heroku (Alternativa)**

**Pasos:**
1. Instala Heroku CLI
2. Crea una app: `heroku create tu-app-name`
3. Agrega PostgreSQL: `heroku addons:create heroku-postgresql:mini`
4. Despliega: `git push heroku main`

---

## 📋 Configuración de Variables de Entorno

### **Variables Requeridas:**
```bash
DATABASE_URL=postgresql://usuario:password@host:puerto/database
FILES_DIR=/tmp/uploads
CORS_ORIGINS=*
```

### **Variables Opcionales:**
```bash
PORT=5000
DEBUG=false
LOG_LEVEL=info
```

---

## 🔄 Actualización del Frontend

Después de desplegar, actualiza la URL de la API en `web/app.js`:

```javascript
// Para Render
const apiBase = 'https://tu-api.onrender.com';

// Para Railway
const apiBase = 'https://tu-app.railway.app';

// Para VPS
const apiBase = 'https://tu-dominio.com/api';
```

---

## 🧪 Pruebas Post-Despliegue

1. **Health Check:**
   ```bash
   curl https://tu-api.com/health
   ```

2. **Subida de Archivos:**
   - Ve a tu URL del frontend
   - Sube un PDF de prueba
   - Verifica que se procese correctamente

3. **Chat:**
   - Haz una pregunta sobre el documento
   - Verifica que obtengas una respuesta

---

## 🛠️ Solución de Problemas

### **Error de CORS:**
```javascript
// En la API, asegúrate de que CORS esté configurado
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### **Error de Base de Datos:**
- Verifica que `DATABASE_URL` esté correcta
- Asegúrate de que la base de datos esté activa
- Revisa los logs de la aplicación

### **Error de Archivos:**
- Verifica que `FILES_DIR` tenga permisos de escritura
- En servicios cloud, usa `/tmp` para archivos temporales

---

## 📊 Monitoreo

### **Logs:**
```bash
# Render
render logs --service tu-api

# Railway
railway logs

# VPS
docker-compose logs -f
```

### **Métricas:**
- Uso de CPU y memoria
- Tiempo de respuesta de la API
- Número de archivos procesados

---

## 🔒 Seguridad

### **Recomendaciones:**
1. Usa HTTPS en producción
2. Configura rate limiting
3. Valida tipos de archivo
4. Limita tamaño de archivos
5. Usa variables de entorno para secretos

### **Variables de Entorno Seguras:**
```bash
# Nunca en el código
DATABASE_URL=postgresql://usuario:password@host/db
API_KEY=tu-api-key-secreta
```

---

## 🎯 Próximos Pasos

1. **Despliega en tu plataforma preferida**
2. **Configura un dominio personalizado**
3. **Implementa autenticación si es necesario**
4. **Agrega más funcionalidades**
5. **Optimiza el rendimiento**

¡Tu chatbot ODR estará online y disponible para todos! 🚀
