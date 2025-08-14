#!/bin/bash

# Script de despliegue para VPS
echo "🚀 Desplegando ODR Chatbot en VPS..."

# Instalar Docker si no está instalado
if ! command -v docker &> /dev/null; then
    echo "📦 Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo usermod -aG docker $USER
fi

# Instalar Docker Compose si no está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Crear directorio del proyecto
mkdir -p /opt/odr-chatbot
cd /opt/odr-chatbot

# Clonar el repositorio (reemplaza con tu URL)
# git clone https://github.com/tu-usuario/odr-chatbot.git .

# Copiar archivos de configuración
cp docker-compose-working.yml docker-compose.yml

# Configurar variables de entorno
cat > .env << EOF
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/odr_chatbot
FILES_DIR=/app/data/uploads
CORS_ORIGINS=*
EOF

# Levantar servicios
echo "🐳 Levantando servicios..."
docker-compose up -d

# Configurar Nginx como proxy reverso
sudo apt update
sudo apt install -y nginx

sudo tee /etc/nginx/sites-available/odr-chatbot << EOF
server {
    listen 80;
    server_name tu-dominio.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /api/ {
        proxy_pass http://localhost:5000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Habilitar sitio
sudo ln -s /etc/nginx/sites-available/odr-chatbot /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

echo "✅ Despliegue completado!"
echo "🌐 Tu chatbot estará disponible en: http://tu-dominio.com"
echo "🔧 API disponible en: http://tu-dominio.com/api/health"
